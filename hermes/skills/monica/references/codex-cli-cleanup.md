# Codex CLI 完全清理（Windows）

适用于完全卸载 Codex CLI（`@openai/codex`）的场景。

## 检查安装点

Windows 上可能同时存在多个安装源：

| 安装源 | 常见路径 |
|--------|---------|
| npm global (via fnm) | `fnm_multishells/*/node_modules/@openai/codex` |
| npm global (via scoop nodejs-lts) | `Roaming/npm/node_modules/@openai/codex` |
| pnpm global | `Local/pnpm/global/*/node_modules/@openai/codex` |
| 配置/数据目录 | `~/.codex/` |

## 清理步骤

### 1. 卸载 npm 全局包

```bash
# fnm 版 Node
npm uninstall -g @openai/codex

# scoop nodejs-lts 版 Node（如果安装了）
/c/Users/77/scoop/apps/nodejs-lts/current/npm.cmd uninstall -g @openai/codex
# 或使用 Roaming/npm 路径
/c/Users/77/AppData/Roaming/npm/npm.cmd uninstall -g @openai/codex
```

### 2. 卸载 pnpm 全局包

```bash
pnpm remove -g @openai/codex
```

### 3. 删除配置目录

```bash
rm -rf ~/.codex
```

### 4. 清理残留 shim 文件

```bash
# pnpm shims
rm -f /c/Users/77/AppData/Local/pnpm/codex*
# Roaming npm shims  
rm -f /c/Users/77/AppData/Roaming/npm/codex*
# fnm multishell shims（大量过期软链）
find /c/Users/77/AppData/Local/fnm_multishells -name 'codex' -type f -delete
```

### 5. 修复 PowerShell profile 硬编码路径

**问题**：profile.ps1 中 `$codexCliPath` 硬编码了旧的 pnpm 路径，包卸载后该路径失效。

**修复**：改为 `Get-Command <name>` 动态查找

```powershell
# 错误：硬编码路径
$codexCliPath = "$env:USERPROFILE\AppData\Local\pnpm\codex.ps1"

# 正确：动态查找
$codexCliPath = $null
$codexCmd = Get-Command codex -ErrorAction SilentlyContinue
if ($codexCmd) { $codexCliPath = $codexCmd.Source }
```

## 首次运行的坑

清理后重新安装，首次运行 Codex CLI 时会：
1. 下载 sandbox 环境（`codex.zip` 约 54MB 到 `Temp/`）
2. 子进程初始化可能超时（`timeout waiting for child process to exit`）
3. 显示 `Falling back from WebSockets to HTTPS transport`

这些是正常的。等 zip 下载完后再启动就好了，之后会快很多。
