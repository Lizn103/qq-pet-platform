# 换机器/新设备完整部署指南（一键恢复到能用）

适用场景：**本机损坏/重装/换新电脑**，从零恢复到「平台+萌卡+固定网址」都能用。

## 换设备必看：哪些不用重弄，哪些要重新弄

| 项目 | 换设备后 | 原因 |
|---|---|---|
| **域名 jwerw.work** | ✅ **不用动** | 域名在云端（阿里云+Cloudflare），跟设备无关 |
| **Cloudflare 账号** | ✅ 不用动 | 云端，登录即可 |
| **DNS 记录**（pet/mengka.jwerw.work 的 CNAME） | ✅ 不用动 | 存在 Cloudflare，指向隧道ID，永久有效 |
| **固定网址** | ✅ 不用动 | pet/mengka.jwerw.work 指向隧道，只要新设备上的隧道用同一个ID就跑通 |
| **萌卡/平台程序** | ⚠️ 要重装 | 程序在本机，新机器要下载安装（本页下方步骤） |
| **隧道（cloudflared）** | ⚠️ 二选一 | 见下方「路线选择」 |
| **QQ 登录态** | ⚠️ 要迁移 | 在 `C:\mengka-nt\data\`，拷目录即保留；不拷则重新扫码登录 |
| **平台数据**（账号/宠物/金币） | ⚠️ 要迁移 | 在 `C:\QQ pet\data\qq-pet.db`，拷文件即保留 |
| **守护/备份/域名提醒** | ⚠️ 要重装 | 脚本+计划任务在旧机器上 |
| **萌卡插件令牌** | ⚠️ 可能变 | 若重新建插件服务，令牌会变，需同步更新平台节点配置 |

### 路线选择（关键）

**路线A：整目录拷贝（推荐，最快）**
旧机器还在时，把这三个目录整个拷到新机器：
- `C:\QQ pet`（平台+数据库+守护脚本+cloudflared）
- `C:\mengka-nt`（萌卡+QQ登录态）
- `C:\Users\Administrator\.cloudflared`（隧道凭据+config）

> 拷贝后：**域名/DNS/隧道全部不用重配**，新机器直接开机自启用。只需确认 `.cloudflared` 里的隧道ID与云端一致即可。

**路线B：从零重建（旧机器没了时）**
按本文第1~7步走：装程序 → 授权隧道 → 配DNS（若DNS记录还在则跳过）→ 登录QQ → 装守护。

> 域名始终在云端，**两条路线都不需要改域名、不需要改Cloudflare账号**。


> 前置：下载包里已含 QQ宠物平台 v1.0.1 + 萌卡NT v2.7.x（见 `docs/SOURCES.md` 来源说明）。

---

## 第0步：准备材料（从 GitHub 拿）

| 材料 | 位置 |
|---|---|
| 平台 Windows 包 | 本仓库 Release `packages-latest` → `mengka-pet-1.0.1-windows-amd64.zip` |
| 萌卡 Windows 包 | `mengka-nt-2.7.x-windows-amd64.zip`（萌卡 GitHub Releases 或本仓库 Release） |
| 敏感信息 | **私有仓库 `qq-pet-keys` → `SENSITIVE-INFO.txt`**（密码/令牌/账号） |
| 运维手册 | 本仓库 `docs/OPERATIONS.md` |
| 本机旧数据（可选） | 如果有旧机器：`C:\QQ pet\data\qq-pet.db`、`C:\mengka-nt\data\` 直接拷过来可保留账号登录态和宠物数据 |

---

## 第1步：安装平台

1. 解压 `mengka-pet-1.0.1-windows-amd64.zip` 到 `C:\QQ pet\`
2. 准备数据目录：`C:\QQ pet\data\`（管理员账号首次启动初始化时设置）
3. 启动：
   ```
   C:\QQ pet\qq-pet-server.exe
   C:\QQ pet\qq-pet-frontend.exe
   ```
4. 浏览器开 `http://127.0.0.1:5173`，注册/登录管理员

> 有旧数据：把备份的 `qq-pet.db` 放回 `C:\QQ pet\data\` 再启动，账号/宠物/金币全保留。

---

## 第2步：安装萌卡NT

1. 解压 `mengka-nt-2.7.x-windows-amd64.zip` 到 `C:\mengka-nt\`
2. 启动 `C:\mengka-nt\mengka-nt.exe`，浏览器开 `http://127.0.0.1:7878` 初始化管理员
3. （可选）有旧数据：把旧 `C:\mengka-nt\data\` 覆盖过来，QQ 登录态免重登

---

## 第3步：萌卡插件服务（平台接线）

1. 萌卡 WebUI → 插件服务 → 添加服务：
   - 名称：测试
   - 模式：`正向 WS`，监听 `127.0.0.1:7879`
   - 记下生成的**服务令牌**
2. 平台管理端 → 萌卡/机器人节点 → 添加节点：
   - 主机 `127.0.0.1`、端口 `7879`、令牌（上面那个）
3. 平台显示「已连接」即接通

---

## 第4步：登录 QQ 账号

- 萌卡账号管理 → 添加账号 → 扫码/密码登录
- 协议选 **Phone 9.2.70**，设备指纹选 Ann14（或新建）
- 平台「账号管理」→ 添加同号（若平台提示已存在，直接用萌卡里已登录号）

---

## 第5步：固定网址（Cloudflare 隧道）

需要：域名（jwerw.work）+ Cloudflare 账号（见《敏感信息清单》）。

1. 授权本机：
   ```
   cd C:\QQ pet
   cloudflared.exe tunnel login   # 浏览器授权（登录 Cloudflare）
   ```
2. 建隧道（若 DNS 已配过可直接 run）：
   ```
   cloudflared.exe tunnel create qqpet-main
   cloudflared.exe tunnel route dns <隧道ID> pet.jwerw.work
   cloudflared.exe tunnel route dns <隧道ID> mengka.jwerw.work
   ```
3. 写 `C:\Users\Administrator\.cloudflared\config.yml`（模板见 `docs/tutorials/10-domain-fixed-url-ch.md`）
4. 启动：`cloudflared.exe tunnel run qqpet-main`
5. 验证：手机开 `https://pet.jwerw.work`

---

## 第6步：守护与备份（建议装）

1. 复制守护脚本 `tunnel-keeper.py`、备份脚本 `daily-backup.py`、域名监控 `domain-watch.py`（内容见旧机或运维手册）
2. 启动文件夹放 `qq-pet-autostart.vbs`（开机自启，模板在运维手册）
3. 注册计划任务：每日备份 + 域名到期提醒（命令见运维手册）

---

## 第7步：验证清单

- [ ] `http://127.0.0.1:5173` 平台能开、能登录（admin）
- [ ] `http://127.0.0.1:7878` 萌卡能开、账号在线
- [ ] 平台萌卡节点状态「已连接」
- [ ] https://pet.jwerw.work 手机能开
- [ ] https://mengka.jwerw.work 手机能开
- [ ] 每日备份任务已注册（QQPetDailyBackup）
- [ ] 域名到期监控已注册（QQPetDomainWatch）

## 故障速查

| 症状 | 原因/解法 |
|---|---|
| 5173 打不开 | server 没起 / 端口占用 → 重启 process，改 FRONTEND_PORT |
| 7878 打不开 | 萌卡没起 / 端口占用 |
| 平台「服务器暂时不可用」 | 萌卡节点断了 → 管理端重连；或重启萌卡 |
| 固定网址打不开 | 隧道进程在吗？DNS 生效没？域名到期没？看运维手册 |
| 开始活动 135064 | 萌卡还没适配 9.3（等上游），手机QQ手动替代 |
