# Viking (GPS Tool) Install on WSL Without Sudo

**Disambiguation:** This is about the **Viking GPS data editor** (`apt: viking`), NOT the ByteDance OpenViking context database. See `references/byteDance-openviking.md` for that project.

## Context

Installing `viking` — a GTK+3 GPS data editor/viewer — on WSL (Ubuntu 22.04) where sudo is disabled.

## Full Session Commands

### 1. Check package availability
```bash
apt-cache search viking
# → viking - GPS data editor, analyzer and viewer
```

### 2. Download .deb package + dependencies
```bash
cd /tmp
apt-get download viking
apt-cache depends viking | grep "Depends:" | awk '{print $2}' | while read pkg; do
  apt-get download "$pkg" 2>&1
done
# Downloaded 27 .deb files
```

### 3. Extract to local prefix
```bash
mkdir -p ~/local
cd /tmp
for deb in *.deb; do
  dpkg-deb -x "$deb" ~/local/
done
```

### 4. Check missing libraries
```bash
export LD_LIBRARY_PATH=~/local/usr/lib/x86_64-linux-gnu:~/local/usr/lib
ldd ~/local/usr/bin/viking 2>&1 | grep "not found"
# Initially 7 missing → down to 3 after extraction
# Still missing: libboost_filesystem.so.1.74.0, libboost_regex.so.1.74.0, libexiv2.so.27
```

### 5. Download remaining transitive deps
```bash
apt-get download libboost-filesystem1.74.0 libboost-regex1.74.0 libexiv2-27
# Extract again
for deb in *.deb; do
  dpkg-deb -x "$deb" ~/local/
done
# Now 0 missing libs
```

### 6. Fix GDK pixbuf (GTK requirement)
```bash
export LD_LIBRARY_PATH=$HOME/local/usr/lib/x86_64-linux-gnu:$HOME/local/usr/lib
GDK_PIXBUF_MODULEDIR=$HOME/local/usr/lib/x86_64-linux-gnu/gdk-pixbuf-2.0/2.10.0/loaders \
$HOME/local/usr/lib/x86_64-linux-gnu/gdk-pixbuf-2.0/gdk-pixbuf-query-loaders \
> $HOME/local/usr/lib/x86_64-linux-gnu/gdk-pixbuf-2.0/2.10.0/loaders.cache
```

### 7. Create wrapper script
```bash
cat > ~/local/bin/viking-wrapper << 'EOF'
#!/bin/bash
export DISPLAY=:0
export WAYLAND_DISPLAY=wayland-0
export XDG_RUNTIME_DIR=/mnt/wslg/runtime-dir
export LD_LIBRARY_PATH=$HOME/local/usr/lib/x86_64-linux-gnu:$HOME/local/usr/lib
export GDK_PIXBUF_MODULE_FILE=$HOME/local/usr/lib/x86_64-linux-gnu/gdk-pixbuf-2.0/2.10.0/loaders.cache
exec $HOME/local/usr/bin/viking "$@"
EOF
chmod +x ~/local/bin/viking-wrapper
```

### 8. Verify version
```bash
$HOME/local/usr/bin/viking --version
# → viking 1.10
```

## Key Details

- **Package:** `viking` (1.10-2), GPS data editor, GTK+3 GUI
- **Total .deb files downloaded:** 30 (viking + direct deps + transitive deps)
- **WSLg display:** DISPLAY=:0, WAYLAND_DISPLAY=wayland-0, XDG_RUNTIME_DIR=/mnt/wslg/runtime-dir
- **Verification:** GUI window launched and stayed running (confirmed via `process poll`)

## Pitfalls Encountered

1. `apt-cache depends` only gets direct dependencies — missing boost and exiv2 libs required a second pass
2. `gdk-pixbuf-query-loaders` must run before any GTK app works (loaders.cache needed)
3. WSLg installed but `DISPLAY` was empty — manually set to `:0`
