# Errors

Command failures and integration errors.

---

## [ERR-20260503-001] gateway_not_running

**Logged**: 2026-05-03T22:28:00
**Priority**: high
**Status**: resolved
**Area**: infra

### Summary
飞书/微信 bot 不响应，原因是 gateway 进程没有在运行。

### Error
用户反馈"机器人没反应"或"bot not responding"

### Context
- gateway 进程未启动或意外退出
- WSL 下没有 systemd 自启，gateway 停止后不会自动恢复

### Suggested Fix
1. `hermes gateway status` 检查
2. 如未运行：`hermes gateway run`
3. WSL 下用 tmux 持久化：`tmux new-session -d -s hermes 'hermes gateway run'`

### Metadata
- Reproducible: yes
- Pattern-Key: infra.gateway-diagnosis

---

## [ERR-20260503-002] sudo_disabled

**Logged**: 2026-05-03T22:28:00
**Priority**: high
**Status**: resolved
**Area**: infra

### Summary
WSL 中 sudo 命令返回权限错误，因为 Windows 设置中禁用了 WSL sudo。

### Error
```
sudo: unable to resolve host
sudo: effective uid is not 0, is /usr/bin/sudo on a filesystem with the 'nosuid' option set or an NFS filesystem without root privileges?
```

### Context
- WSL 环境
- Windows 中设置了关闭 sudo
- 无法使用 apt install, systemctl, service 等需要 root 的命令

### Suggested Fix
需要管理员权限的操作走 Windows 端（PowerShell/CMD 管理员）或使用 netsh portproxy 等替代方案。

### Metadata
- Reproducible: yes
- Pattern-Key: infra.wsl-no-sudo

---

## [ERR-20260503-003] gateway_model_mismatch

**Logged**: 2026-05-03T22:28:00
**Priority**: high
**Status**: resolved
**Area**: config

### Summary
Gateway 使用的模型和用户在 CLI 中看到的不一致，因为 CLI 可以临时切换模型但 gateway 只读 config.yaml。

### Error
用户："为什么 bot 回复的模型和我说不一样？"

### Context
- CLI 通过 -m 或 /model 切换了模型
- gateway 进程没有重启，仍使用旧的 config.yaml 配置
- 用户预期 bot 使用和 CLI 相同的模型

### Suggested Fix
1. 检查 `grep -A3 "^model:" ~/.hermes/config.yaml`
2. 更新 model.default
3. 重启 gateway：先 kill 旧进程再 `hermes gateway run`

### Metadata
- Reproducible: yes
- Pattern-Key: infra.gateway-model-mismatch

---
