# Codex Desktop 启动方法

## 关键发现

Codex 桌面版是 **Windows Store MSIX 应用**（包名：`OpenAI.Codex_2p2nqsd0c76g0`），不是独立安装的 Electron 应用。

## 启动命令

```bash
# 方法1：通过 PowerShell 启动（MSIX URI）
powershell.exe -Command "Start-Process 'codex:'"

# 方法2：通过 explorer 启动
powershell.exe -Command "explorer.exe 'codex:'"
```

## 进程验证

Codex 启动后会看到多个进程：
```
Codex.exe                    ~290MB  主进程
Codex.exe                    ~35MB   辅助进程
Codex.exe                    ~210MB  渲染进程
codex-acp.exe                ~18MB   ACP 进程
codex.exe                    ~75MB   子进程
```

## 数据目录

Codex 的用户数据存储在以下路径（符号链接到 WSL 文件系统）：
```
C:/Users/77/AppData/Local/Packages/OpenAI.Codex_2p2nqsd0c76g0/
├── AC                  → D:/WpSystem/.../AC
├── AppData             → D:/WpSystem/.../AppData
├── LocalCache          → D:/WpSystem/.../LocalCache
├── LocalState          → D:/WpSystem/.../LocalState
└── RoamingState        → D:/WpSystem/.../RoamingState
```

## 配置位置

CLI 配置：`C:/Users/77/AppData/Roaming/Codex/config.toml`
- provider: `transform`（自定义 endpoint）
- model: `gpt-5.4`
- base_url: `https://rsxermu666.cn/openai`

## 注意事项

- Codex 桌面版不能通过 `codex` 命令直接启动 GUI（那是 CLI）
- 需要通过 Windows 的 MSIX URI `codex:` 触发启动
- 如果 `Start-Process 'codex:'` 无反应，检查 Windows Store 版本是否安装
