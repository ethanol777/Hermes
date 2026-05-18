# MEMORY.md 写入冲突分析

## 现象（旧 daemon 方案）

Daemon 日志显示 3 次成功学习（"Learned something!"），但
`MEMORY.md` 最终只有初始头部，daemon 追加的学习内容全部丢失。

## 根因

两个系统同时写 MEMORY.md：
1. **self-learn daemon（python 后台进程）** — spawn 子进程追加上次学习内容
2. **Hermes 启动时的持久化内存同步** — 覆盖文件

## 解决方案（2026-05-13）

**废弃 daemon 方案，改用 cron 任务让 Monica 亲自学。**

- Monica 本人是唯一写入者，不会冲突
- 学到的内容直接在上下文里，不需要绕过 file tools
- 没有子进程，没有竞态

## 验证

```bash
# 确认 daemon 已停
tasklist //fi "IMAGENAME eq pythonw.exe"
# 应该只看到 Gateway 的 pythonw，没有 self_learn 的

# 确认 cron 在跑
hermes cron list
# 应该看到 "莫妮卡自主学习" 状态 scheduled

# 查看学习记录
grep "auto-learned" ~/AppData/Local/hermes/memories/MEMORY.md
```
