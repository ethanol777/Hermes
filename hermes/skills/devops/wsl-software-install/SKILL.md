---
name: wsl-software-install
description: Install Linux packages on WSL without sudo/root — apt debs, pip, snap, and local extraction workflows for environments where sudo is disabled
trigger:
  - install in WSL context
  - sudo/apt install fails with password required
  - no sudo or root access restrictions on WSL
  - need to install GUI apps on WSL (WSLg)
  - apt-get install fails due to permission
tags: [wsl, install, apt, no-sudo, package-management, devops]
---

# WSL Software Install (No Sudo)

Techniques for installing Linux packages on WSL when sudo is disabled (Windows Settings → Developer → Sudo disabled), or in any restricted environment where you lack root.

## Quick Reference

**Preferred methods (no sudo needed):**
| Method | Works for | Complexity |
|--------|-----------|------------|
| pip --user | Python packages | Easy |
| npm install -g (in user dir) | Node packages | Easy |
| apt-get download + dpkg-deb -x | Any apt package | Medium |
| cargo install | Rust tools | Easy |
| Go install | Go binaries | Easy |
| Static binaries (curl to ~/local/bin) | CLI tools | Easy |
| Snap (requires sudo) | ❌ Fails | — |

## Method 1: Pip / Node / Rust / Go (no sudo needed)

```bash
# Python
pip3 install --user <package>
# Or with pipx (isolated)
pipx install <package>

# Node.js
npm install -g <package>    # if prefix ~/npm is configured
# Or: npm install <package>
export PATH="$HOME/node_modules/.bin:$PATH"

# Rust
cargo install <package>

# Go
go install <package>@latest
```

## Method 2: Apt packages via .deb extraction (no sudo)

When `sudo apt install <package>` fails because sudo is disabled.

### Step 1: Download .deb + dependencies

```bash
cd /tmp
apt-get download <package>
# Get direct dependencies:
apt-cache depends <package> | grep "Depends:" | awk '{print $2}' | xargs apt-get download
```

**Pitfall:** This only gets direct deps. Transitive deps may still be missing. Run `ldd` after extraction to find what's still needed, then download those too.

### Step 2: Extract to local prefix

```bash
mkdir -p ~/local
# Extract all .deb files
for deb in /tmp/*.deb; do
  dpkg-deb -x "$deb" ~/local/
done
```

### Step 3: Set environment

```bash
export LD_LIBRARY_PATH=$HOME/local/usr/lib/x86_64-linux-gnu:$HOME/local/usr/lib
export PATH=$HOME/local/usr/bin:$HOME/local/bin:$PATH
```

### Step 4: Fix gdk-pixbuf for GTK apps

If the app uses GTK/GNOME (most GUI apps), generate the pixbuf loaders cache:

```bash
export LD_LIBRARY_PATH=$HOME/local/usr/lib/x86_64-linux-gnu:$HOME/local/usr/lib
GDK_PIXBUF_MODULEDIR=$HOME/local/usr/lib/x86_64-linux-gnu/gdk-pixbuf-2.0/2.10.0/loaders \
$HOME/local/usr/lib/x86_64-linux-gnu/gdk-pixbuf-2.0/gdk-pixbuf-query-loaders \
> $HOME/local/usr/lib/x86_64-linux-gnu/gdk-pixbuf-2.0/2.10.0/loaders.cache
```

### Step 5: Create a wrapper script (for GUI apps)

```bash
cat > ~/local/bin/<name>-wrapper << 'EOF'
#!/bin/bash
export DISPLAY=:0
export WAYLAND_DISPLAY=wayland-0
export XDG_RUNTIME_DIR=/mnt/wslg/runtime-dir
export LD_LIBRARY_PATH=$HOME/local/usr/lib/x86_64-linux-gnu:$HOME/local/usr/lib
export GDK_PIXBUF_MODULE_FILE=$HOME/local/usr/lib/x86_64-linux-gnu/gdk-pixbuf-2.0/2.10.0/loaders.cache
exec $HOME/local/usr/bin/<binary> "$@"
EOF
chmod +x ~/local/bin/<name>-wrapper
```

Add to ~/.bashrc or ~/.zshrc for persistence:

```bash
export PATH=$HOME/local/bin:$HOME/local/usr/bin:$PATH
export LD_LIBRARY_PATH=$HOME/local/usr/lib/x86_64-linux-gnu:$HOME/local/usr/lib
```

## Method 3: Static binaries / AppImage

Many CLI tools distribute as standalone binaries:

```bash
mkdir -p ~/local/bin
# Download + chmod
curl -sL <url> -o ~/local/bin/<tool>
chmod +x ~/local/bin/<tool>
```

**AppImages** need FUSE — check if available on your WSL:
```bash
which fuse
# If no FUSE: extract AppImage with --appimage-extract
./tool.AppImage --appimage-extract
./squashfs-root/AppRun
```

## Method 4: Conda / Mamba (for data science tools)

```bash
# Install miniconda to user dir (no sudo)
curl -sL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh
bash /tmp/miniconda.sh -b -p $HOME/miniconda3
$HOME/miniconda3/bin/conda init
```

## WSLg GUI Requirements

To run GUI apps on WSL, you need WSLg (Windows 11 WSL with GUI support):

```bash
# Verify WSLg
ls /mnt/wslg/versions.txt 2>/dev/null && echo "WSLg available" || echo "No WSLg"

# Required display vars
export DISPLAY=:0
export WAYLAND_DISPLAY=wayland-0
export XDG_RUNTIME_DIR=/mnt/wslg/runtime-dir
```

**Pitfall:** If `DISPLAY` is empty despite WSLg being installed, set it manually to `:0`. The Wayland socket at `/mnt/wslg/runtime-dir/wayland-0` should exist.

## Common Pitfalls

### ldconfig / ldconfig not available
Can't run `ldconfig` (needs root). Find missing libs with:
```bash
LD_LIBRARY_PATH=~/local/usr/lib/x86_64-linux-gnu ldd ~/local/usr/bin/<binary> | grep "not found"
```

### Snap needs sudo
```bash
snap install <pkg>
# → error: access denied (try with sudo)
```
Snap cannot run without sudo. Use .deb extraction instead.

### Systemd services not available
GUI apps that need systemd (e.g., `systemctl --user`) may not work on WSL without additional setup. Prefer standalone binaries or simple GUI apps.

### WSLg not working
If DISPLAY set but app doesn't show:
1. Check `/mnt/wslg/` exists
2. Try `DISPLAY=:0` (most common)
3. Try `DISPLAY=$(hostname).local:0`
4. Could use VcXsrv on Windows instead

## References

- `references/openviking-install.md` — Full session transcript: installing viking (GPS tool) on WSL without sudo, including the exact deb list, dependency resolution, and wrapper creation.

## See Also

- `wsl-networking` — WSL network config (port forwarding, tunnels) for accessing installed services from LAN
