# 换设备 10 分钟恢复清单（本机方案）

**适用**：经常换电脑/换系统，但暂不迁云端。网站域名永远不变（在云端），要搬的只是本机程序和数据。

## 一、每次换设备前：备份这三样（U盘/网盘/另一台电脑）

| 顺序 | 要拷的 | 说明 |
|---|---|---|
| 1 | `C:\QQ pet` 整个目录 | 平台程序 + 数据库 + 守护脚本 + cloudflared（76MB） |
| 2 | `C:\mengka-nt` 整个目录 | 萌卡 + QQ登录态（86MB，含免密登录） |
| 3 | `C:\Users\Administrator\.cloudflared` | 隧道凭据——**域名不变的钥匙**（很小） |

可选一并拷：`C:\qbot\code\config.ini`（机器人凭据）、`C:\backup`（历史备份）

> 💡 强烈建议：把这三个目录打个 zip 传到你的 GitHub 私有仓库 `qq-pet-keys` 或云盘，换设备=下载解压，连 U 盘都不用。

## 二、在新设备上恢复（10 分钟）

1. 解压三个目录回原位：
   - `C:\QQ pet`、`C:\mengka-nt`、`C:\Users\Administrator\.cloudflared`
2. 双击启动（或放到开机自启）：
   ```
   C:\mengka-nt\mengka-nt.exe
   C:\QQ pet\qq-pet-server.exe
   C:\QQ pet\qq-pet-frontend.exe
   ```
3. 启动守护（可选）：
   ```
   python C:\QQ pet\tunnel-keeper.py
   ```
4. 等 30 秒 → 手机打开 `https://pet.jwerw.work` 验证

**域名/DNS/隧道全部不用重配**——因为 `.cloudflared` 目录带走了隧道凭据，Cloudflare 云端配置没变。

## 三、常见情况

| 情况 | 处理 |
|---|---|
| 新电脑没装 Python | 只影响守护脚本，平台/萌卡/隧道照常；装 Python 后补守护 |
| 端口被占用 | 杀占用进程，或改 FRONTEND_PORT |
| 拷贝后萌卡要重新登录 | 说明 `mengka-nt\data` 没拷全（登录态在里面），重新扫码登录即可 |
| 隧道起不来 | 检查 `.cloudflared` 是否在 `C:\Users\Administrator\` 下，且含 `cert.pem` 和 `<隧道ID>.json` |
| 平台密码忘了 | 见 `SENSITIVE-INFO.txt` 或 `admin_init.txt` |

## 四、正向提醒

- 换设备前**先跑一次每日备份**（`python C:\QQ pet\daily-backup.py`）确保数据库最新
- 换完设备后在手机上确认两个网址：pet.jwerw.work（平台）+ mengka.jwerw.work（萌卡）
- 域名到期提醒（每天09:00自动检查QQ通知）换设备后要重新注册计划任务（见运维手册）

---
*如果哪天觉得"每次换设备还要搬 10 分钟"都麻烦 → 转云端方案（scripts/deploy-cloud.sh 已备好）。*
