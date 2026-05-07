# WSL Software Install (No Sudo)

Techniques for installing Linux packages on WSL when sudo is disabled.

## Quick Method Selection

| Method | Works for | Complexity |
|--------|-----------|------------|
| pip --user | Python packages | Easy |
| npm install -g (user dir) | Node packages | Easy |
| apt-get download + dpkg-deb -x | Any apt package | Medium |
| cargo install | Rust tools | Easy |
| Go install | Go binaries | Easy |
| Static binaries (curl to ~/local/bin) | CLI tools | Easy |
| Conda/Mamba | Data science tools | Medium |

## Method 1: Language-Specific Package Managers

```bash
# Python
pip3 install --user <package>
pipx install <package>    # isolated

# Node.js
npm install -g <package>
export PATH="$HOME/node_modules/.bin:$PATH"

# Rust
cargo install <package>

# Go
go install <package>@latest
```

## Method 2: Apt Packages via .deb Extraction

When `sudo apt install` fails:

```bash
cd /tmp
apt-get download <package>
apt-cache depends <package> | grep "Depends:" | awk '{print $2}' | xargs apt-get download

mkdir -p ~/local
for deb in /tmp/*.deb; do dpkg-deb -x "$deb" ~/local/; done

export LD_LIBRARY_PATH=$HOME/local/usr/lib/x86_64-linux-gnu:$HOME/local/usr/lib
export PATH=$HOME/local/usr/bin:$HOME/local/bin:$PATH
```

### For GUI Apps (GTK)

Generate gdk-pixbuf loaders cache:
```bash
GDK_PIXBUF_MODULEDIR=$HOME/local/usr/lib/x86_64-linux-gnu/gdk-pixbuf-2.0/2.10.0/loaders \
$HOME/local/usr/lib/x86_64-linux-gnu/gdk-pixbuf-2.0/gdk-pixbuf-query-loaders \
> $HOME/local/usr/lib/x86_64-linux-gnu/gdk-pixbuf-2.0/2.10.0/loaders.cache
```

Create wrapper script:
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

## Method 3: Static Binaries / AppImages

```bash
mkdir -p ~/local/bin
curl -sL <url> -o ~/local/bin/<tool>
chmod +x ~/local/bin/<tool>
# AppImages: extract if FUSE not available
./tool.AppImage --appimage-extract
./squashfs-root/AppRun
```

## Method 4: Conda / Mamba

```bash
curl -sL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh
bash /tmp/miniconda.sh -b -p $HOME/miniconda3
$HOME/miniconda3/bin/conda init
```

## Common Pitfalls

- **Snap** — always needs sudo. Use .deb extraction instead.
- **Systemd services** — limited WSL support. Prefer standalone binaries.
- **Missing libraries** — use `ldd ~/local/usr/bin/<binary> | grep "not found"` to find them
- **WSLg** — verify with `ls /mnt/wslg/versions.txt 2>/dev/null`

## See Also

- `references/viking-gps-install.md` — Full walkthrough: installing the Viking GPS tool via .deb extraction
