---
name: wsl
description: Complete guide for Windows Subsystem for Linux (WSL) — networking configuration, software installation without sudo, and remote access via Cloudflare Tunnel.
version: 1.0.0
author: Hermes Agent (consolidated)
license: MIT
metadata:
  hermes:
    tags: [wsl, windows-subsystem-for-linux, networking, software-install, devops]
---

# WSL (Windows Subsystem for Linux) Guide

Comprehensive guide for working in WSL environments — covering networking configuration, installing software without root access, and exposing local services to the internet.

## What's Inside

This skill consolidates knowledge about WSL usage into one place. See the `references/` directory for detailed walkthroughs:

- `references/networking.md` — WSL networking config, port forwarding from Windows, accessing WSL from LAN
- `references/software-install.md` — Installing Linux packages without sudo/root via apt, pip, conda, nix
- `references/remote-access.md` — Exposing WSL services to the internet via Cloudflare Tunnel (trycloudflare)

## Quick Reference

### WSL Networking

WSL gets its own virtual IP from Hyper-V. Common commands:

```bash
# Find WSL's IP address
ip addr show eth0 | grep inet

# Find Windows host IP from within WSL (accessible via this IP)
# Windows host is reachable at the default gateway
ip route | grep default

# Forward a port from Windows to WSL (run on Windows PowerShell as Admin)
# netsh interface portproxy add v4tov4 listenport=8788 listenaddress=0.0.0.0 connectport=8788 connectaddress=$(wsl hostname -I)
```

### Installing Software Without Sudo

```bash
# Python packages via pip (user install)
pip install --user <package>

# Conda (no sudo needed for install)
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh -b -p ~/miniconda3
~/miniconda3/bin/conda install <package>

# Nix package manager (no sudo)
sh <(curl -L https://nixos.org/nix/install) --no-daemon
nix-env -i <package>
```

### Remote Access via Cloudflare Tunnel

```bash
# One-liner to expose local web service
curl -sL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o ~/.hermes/cloudflared
chmod +x ~/.hermes/cloudflared
~/.hermes/cloudflared tunnel --url http://localhost:8788
```

## See Also

- `references/networking.md` — Full WSL networking guide with port forwarding, DNS, and cross-subnet access
- `references/software-install.md` — Detailed package installation methods for WSL
- `references/remote-access.md` — Cloudflare Tunnel setup for exposing services
- `references/browser-setup.md` — Installing headless Chromium via Playwright for Hermes browser tools (no sudo needed)
