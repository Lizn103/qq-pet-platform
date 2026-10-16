# 运维手册 / Operations Manual

本手册面向**任何新接管者**：按本文可完整了解并操作整套「QQ宠物平台 + 萌卡NT」系统——
包括换账号、换域名、换机器、换人，全程无障碍。

> 📅 上次更新：2026-10-17 ｜ ⚠️ 域名 jwerw.work 2026-10-28 到期（见第 8 节）

---

## 1. 系统全景

```
[你的手机/电脑浏览器]
        │ https://pet.jwerw.work / https://mengka.jwerw.work
        ▼
[Cloudflare 全球网络] ← 域名 jwerw.work 托管于此（NS 已指向 Cloudflare）
        │ 隧道 qqpet-main（cloudflared）
        ▼
[本机 Windows 服务器]
  ├── qq-pet-frontend.exe  (:5173)  平台网页
  ├── qq-pet-server.exe    (:2345)  平台API + 数据库(内置 SQLite)
  ├── mengka-nt.exe        (:7878管理台 / :7879插件服务)  QQ协议框架
  ├── cloudflared.exe ×1   (命名隧道 qqpet-main)
  └── tunnel-keeper.py     (守护: 隧道自动重启 + 萌卡断线自愈 + QQ通知)
```

**数据流**：浏览器 → Cloudflare → 隧道 → 本机前端/API → 萌卡(NT QQ协议) → 腾讯QQ服务器 → QQ宠物。

---

## 2. 组件与版本

| 组件 | 用途 | 位置 | 当前版本 |
|---|---|---|---|
| QQ宠物平台 | 用户前台+管理后台 | `C:\QQ pet\` | v1.0.1（go1.26 构建） |
| 萌卡NT | QQ 协议框架（登录 QQ、调宠物接口） | `C:\mengka-nt\` | v2.7.2（最新） |
| cloudflared | 内网穿透隧道 | `C:\QQ pet\cloudflared.exe` | 2026.10.1 |
| tunnel-keeper | 守护脚本 | `C:\QQ pet\tunnel-keeper.py` | v5 |
| 数据库 | 平台数据 | `C:\QQ pet\data\qq-pet.db` | SQLite |
| 萌卡数据 | QQ登录态/账号 | `C:\mengka-nt\data\` | — |

备份目录：`C:\QQ pet-backup-换包前20261017`、`C:\mengka-nt-272-换包前20261017`、`C:\mengka-nt-2.7.1-backup`、`C:\mengka-nt-2.6.9-backup`

---

## 3. 固定网址与域名

| 网址 | 用途 | 说明 |
|---|---|---|
| https://pet.jwerw.work | QQ宠物平台 | 转发到本机 :5173 |
| https://mengka.jwerw.work | 萌卡管理台 | 转发到本机 :7878 |

- 域名注册商：阿里云/万网（账号见第 7 节）
- DNS 托管：Cloudflare（NS = chip.ns.cloudflare.com / sloan.ns.cloudflare.com）
- 隧道：命名隧道 `qqpet-main`（ID 193d8edc-a095-4b17-bdf8-2b4464b85e9e）
- 笔记**千万不要动 NS**、**不要用二级子域**（如 api.pet.xxx 无免费证书），一律用 `pet.` / `mengka.` 一级子域

---

## 4. 关键配置存放位置

| 文件 | 内容 |
|---|---|
| `C:\Users\Administrator\.cloudflared\cert.pem` | Cloudflare 授权证书（保密！泄露=隧道被接管） |
| `C:\Users\Administrator\.cloudflared\193d8edc-….json` | 隧道凭据（保密！） |
| `C:\Users\Administrator\.cloudflared\config.yml` | 隧道转发规则（域名→端口映射） |
| `C:\QQ pet\data\qq-pet.db` | 平台数据库（全部业务数据） |
| `C:\QQ pet\logs\` | 运行日志（tunnel-keeper.log / cloudflared-*.log） |
| `C:\mengka-nt\data\config.db` | 萌卡配置（账号、设备指纹、插件令牌） |
| `C:\mengka-nt\logs\` | 萌卡日志 |
| `C:\qbot\code\config.ini` | QQ官方机器人凭据（appId/secret）+ **你的完整账号体系** |
| `C:\QQ pet\admin_init.txt` | 平台 admin 初始账号密码（UTF-8 BOM） |
| `C:\QQ pet\隧道 URL 文件` | tunnel-url-*.txt（旧版临时隧道遗留，可忽略） |

---

## 5. 日常操作

### 启动/重启整套系统
```powershell
# 平台
Start-Process 'C:\QQ pet\qq-pet-server.exe' -WorkingDirectory 'C:\QQ pet' -WindowStyle Hidden
Start-Process 'C:\QQ pet\qq-pet-frontend.exe' -WorkingDirectory 'C:\QQ pet' -WindowStyle Hidden
# 萌卡
Start-Process 'C:\mengka-nt\mengka-nt.exe' -WorkingDirectory 'C:\mengka-nt' -WindowStyle Hidden
# 守护
Start-Process python 'C:\QQ pet\tunnel-keeper.py' -WorkingDirectory 'C:\QQ pet' -WindowStyle Hidden
```

### 停止
```powershell
Get-Process qq-pet-server,qq-pet-frontend,mengka-nt -ErrorAction SilentlyContinue | Stop-Process -Force
```

### 查看状态
```powershell
netstat -ano | findstr "2345 5173 7878 7879"   # 端口
Get-Process cloudflared,qq-pet-server,qq-pet-frontend,mengka-nt   # 进程
notepad C:\QQ pet\logs\tunnel-keeper.log   # 守护日志
```

### 备份（建议每周）
```powershell
Copy-Item 'C:\QQ pet\data\qq-pet.db' "C:\backup\qq-pet-$(Get-Date -Format yyyyMMdd).db"
Copy-Item 'C:\mengka-nt\data\config.db' "C:\backup\mengka-$(Get-Date -Format yyyyMMdd).db"
```

### 升级萌卡（保留登录态）
1. 备份 `C:\mengka-nt\data`
2. 停萌卡 → 替换 `mengka-nt.exe/public/docs`（**data 不动**）→ 启动
3. 详见萌卡自带的 `docs/upgrade.md`

---

## 6. 换账号接管（新账号如何接手）

### A. 换 Cloudflare 账号 / 换域名
1. 注册新 Cloudflare 账号 → Add a site 添加域名 → 拿到新 NS
2. 去域名注册商改 NS → 等生效
3. 本机：`cd C:\QQ pet; .\cloudflared.exe tunnel login`（用新账号授权）
4. `cloudflared tunnel create qqpet-main`（或复用旧隧道，改 DNS）
5. `cloudflared tunnel route dns <ID> pet.新域名` + `mengka.新域名`
6. 改 `~/.cloudflared/config.yml` 里的域名 → 重启隧道
7. 测试新网址
> 完整图文步骤见 `docs/tutorials/10-domain-fixed-url-ch.md`

### B. 换 GitHub 账号（推代码/教程）
- 在 GitHub 创建新账号 → 把 `Lizn103/qq-pet-platform` fork 过去，或把仓库 transfer/改名
- 本地无需改动（本机用 API 令牌推送，见账号清单；令牌在交接时更新）

### C. 换 QQ 账号（平台绑定的宠物号）
1. 萌卡管理台（https://mengka.jwerw.work）→ 账号管理 → 退出旧账号 → 添加新QQ（扫码/密码）
2. 平台管理台 → QQ账号管理：新端登录、绑定；旧绑定删除
3. 宠物 ID 变化后，平台宠物数据在 `qq-pet.db` 的 pet_profiles 表对应更新（一般自动）

### D. 换机器（迁移整机）
1. 拷贝目录：`C:\QQ pet`、`C:\mengka-nt`、`C:\Users\Administrator\.cloudflared`、`C:\qbot\code\config.ini`
2. 新机器装 Python + 对应服务
3. 用第 5 节命令启动；隧道凭据随.​cloudflared 目录迁移，网址不变
4. 若要迁移萌卡登录态，data 目录一起拷

---

## 7. 账号清单（名称 / 位置）

| 系统 | 账号/身份 | 凭据在哪 |
|---|---|---|
| 平台管理后台 | admin | `C:\QQ pet\admin_init.txt` |
| 萌卡管理台 | anadmin | 萌卡 WebUI 初始化时设置（**找原管理员要**） |
| Cloudflare | 2366820259@qq.com | 密码为注册时自设（**找原管理员要**） |
| GitHub | Lizn103 | GitHub 令牌明文曾泄露，**建议撤销重建** |
| QQ 官方机器人 | config.ini `[QQ_Official]` | `C:\qbot\code\config.ini` |
| 阿里云/万网 | 域名控制台 | 用户本人账号（**换人需在阿里云过户域名**） |
| 腾讯 QQ | 3368623550 | 萌卡 data 缓存登录（免密，勿删 data） |

> 🔒 敏感凭据明文见本机 `C:\QQ pet\SENSITIVE-INFO.txt`（**勿上传仓库/勿发群**）

---

## 8. 域名到期处置（2026-10-28 到期）

**到期前必须处理（建议 10-21 前）**：
- **续费**：阿里云域名控制台 → jwerw.work → 续费。NS 不变 → 固定网址自动恢复，零操作
- **换域名**：按第 6-A 节 + `docs/tutorials/10-domain-fixed-url-ch.md` 全流程重配

到期后未处理：`pet.jwerw.work` / `mengka.jwerw.work` 全部失效，本机服务不受影响（内网 127.0.0.1 仍可访问）。

---

## 9. 已知问题与依赖上游

| 问题 | 状态 |
|---|---|
| QQ宠物「开始活动」报 135064 版本过低 | ⏳ 等萌卡发布 9.3 协议适配（腾讯要求客户端≥9.3，萌卡最高 9.2.70）；萌卡官方 issue #13；手机QQ可正常手动开始活动 |
| 萌卡更新通道 | 仅 GitHub Releases（Carlor-Official/Mengka-NT）；自动更新已开启 |

平台源码/教程仓库：**github.com/Lizn103/qq-pet-platform**
