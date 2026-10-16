# 来源说明 / Sources

记录本仓库内及发布物中每个组件**来自哪个仓库**，避免混淆。

更新日期：2026-10-17

## 组件来源总表

| 组件 / 文件 | 来源仓库 | 类型 | 说明 |
|-------------|----------|------|------|
| **本仓库 (qq-pet-platform)** | fork 自 `yuexl258/memgke-qq-pet` | 上游 fork | 原作者仓库：https://github.com/yuexl258/memgke-qq-pet （v1.0.1，最近提交 2026-09-29，无更新） |
| `backend/` `frontend/` 代码 | `yuexl258/memgke-qq-pet` main 分支 | 上游源码 | 与本仓库相同（fork 时基线），本地只做结构调整 |
| `docs/tutorials/*.md` 教程 | **本仓库自写** | 自建 | 基于本机实际部署与排障经验编写，非上游内容 |
| `docs/install-guide.md` | 本仓库自写 | 自建 | 安装指南 |
| `deploy/` `scripts/` 脚本 | 本仓库自写 | 自建 | Windows 安装/构建/启动脚本 |
| `data/pk-strangers-list.txt` | 原 `pet-pk-strangers.txt`，来自上游仓库根目录 | 上游数据 | 已移动位置 |
| `mengka-pet-1.0.1-windows-amd64.zip` | `yuexl258/memgke-qq-pet` Release v1.0.1 | 上游官方发布物 | 含 qq-pet-server.exe / qq-pet-frontend.exe |
| `mengka-pet-1.0.1-linux-amd64.tar.gz` | `yuexl258/memgke-qq-pet` Release v1.0.1 | 上游官方发布物 | Linux 版平台 |
| `mengka-nt-2.7.x-windows-amd64.zip` | `Carlor-Official/Mengka-NT` Release | 萌卡官方发布物 | 官方仓库：https://github.com/Carlor-Official/Mengka-NT （本站最新 v2.7.2，2026-10-16 发布） |
| `mengka-nt-2.7.x-linux-amd64.tar.gz` | `Carlor-Official/Mengka-NT` Release | 萌卡官方发布物 | Linux 版萌卡NT |
| 旧版备份 `mengka-nt-2.6.9-backup` 等 | `Carlor-Official/Mengka-NT` Release v2.6.9 / v2.7.1 | 萌卡官方发布物 | 本机本地目录，仅供回滚 |

## 与本机部署相关的其他仓库

| 项目 | 仓库 | 说明 |
|------|------|------|
| Ann QQ 机器人（原 qq-bot） | `Lizn103/ann-qq-bot`（自建） | 云机同步 + 机器人本体 |
| QQ挂机保活 | `Lizn103/qq-headless-keep-alive`（自建） | 原 qq-hangup |
| 网易云任务 | `Lizn103/netease-yunbei-task`（自建） | 官方任务工具 |
| 网易云任务备份 | `Lizn103/netease-task-backup`（自建） | 原 `-` 仓库 |
| 小说邮件机器人 | `Lizn103/novel-mail-bot`、`Lizn103/telegram-novel-bot`（自建） | 原 bot / telegram-bot |
| Ann 宠物网站资源 | `Lizn103/ann-pet-web-assets`（自建） | 原 an-app-data |

## 版本号核对（截至 2026-10-17）

- memgke-qq-pet 平台：**v1.0.1**（上游最新，无更新）
- 萌卡NT：**v2.7.2**（官方最新，2026-10-16 发布）
- 平台教程：仓库自写 v1（docs/tutorials/ 下 8 篇）
