# 固定网址（Cloudflare 隧道）配置教程

QQ宠物平台和萌卡NT 通过 Cloudflare 命名隧道获得**永久固定网址**：
- 🐾 QQ宠物平台：`https://pet.jwerw.work`
- 🐹 萌卡管理台：`https://mengka.jwerw.work`

本文记录完整配置流程，以及域名到期后的处理步骤。

---

## ⚠️ 域名到期提醒（重要）

**jwerw.work 到期时间：2026-10-28**（注册于 2025-10-28，一年期）

到期后若未续费：域名失效 → 固定网址全部打不开。

**到期前 7 天（约 10-21）开始处理**，两种选择：

### 方案A：续费（推荐，最简单）
- 去阿里云（万网）域名控制台 → jwerw.work → 续费（一年几十元）
- 续费后 **NS 不变**（已指向 chip/sloan.ns.cloudflare.com），**隧道配置全部不用动**，固定网址自动继续生效

### 方案B：换新域名（如果 jwerw.work 不再用）
- 买新域名（如 xxx.work），按下方「完整配置流程」重新走一遍
- **唯一要改的**：新域名的两个 NS 需要重新去注册商改，然后 `cloudflared tunnel route dns` 重新指 CNAME，`config.yml` 里域名换新

---

## 完整配置流程（从零开始）

### 第1步：注册 Cloudflare 账号
1. dash.cloudflare.com/sign-up
2. 邮箱+密码注册，邮箱验证

### 第2步：添加域名（Add a site）
1. dash.cloudflare.com → **Add a site**
2. 输入域名（如 jwerw.work）→ 选 **Free** 套餐 → 继续
3. DNS 记录页直接 **Continue**（不用添加记录，隧道会建 CNAME）
4. 页面显示**两个 NS 地址**（形如 `chip.ns.cloudflare.com` / `sloan.ns.cloudflare.com`）——记下

### 第3步：修改域名的 NS（去注册商）
1. 阿里云/万网控制台 → 域名管理 → **DNS服务器/DNS修改**
2. 删掉原来的 NS（如 dns9.hichina.com / dns10.hichina.com）
3. 填 Cloudflare 给的两个 NS
4. 保存，等全球生效（10分钟~2小时，用 `nslookup 域名 1.1.1.1` 检查返回 cloudflare 即生效）

### 第4步：授权本机 cloudflared（一次性）
```powershell
cd C:\QQ pet
.\cloudflared.exe tunnel login
# 会输出授权链接，手机或电脑浏览器打开 → 登录 Cloudflare → 选域名 → Allow
# 成功后生成 C:\Users\Administrator\.cloudflared\cert.pem
```

### 第5步：创建命名隧道
```powershell
.\cloudflared.exe tunnel create qqpet-main
# 成功后：Created tunnel qqpet-main with id XXXX  ← 记下 ID
# 凭据写入 ~/.cloudflared\<id>.json
```

### 第6步：配置 DNS 记录（CNAME 指向隧道）
```powershell
.\cloudflared.exe tunnel route dns <隧道ID> pet.jwerw.work
.\cloudflared.exe tunnel route dns <隧道ID> mengka.jwerw.work
```

### 第7步：写 config.yml（转发规则）
文件 `C:\Users\Administrator\.cloudflared\config.yml`：
```yaml
tunnel: qqpet-main
credentials-file: C:/Users/Administrator/.cloudflared/<隧道ID>.json

ingress:
  - hostname: pet.jwerw.work
    service: http://127.0.0.1:5173
  - hostname: mengka.jwerw.work
    service: http://127.0.0.1:7878
  - service: http_status:404
```

### 第8步：启动固定隧道
```powershell
.\cloudflared.exe tunnel run qqpet-main
```
测试：手机浏览器打开 `https://pet.jwerw.work`（前端）、`https://mengka.jwerw.work`（萌卡）。

### 第9步：守护脚本
`C:\QQ pet\tunnel-keeper.py`（v5）每 60 秒检查隧道进程，挂了自动重启 + QQ 通知；同时保留萌卡断线自愈。

---

## 注意事项

1. **一级子域证书**：Cloudflare 免费套餐自动为 `*.域名` 签发证书，所以用 `pet.` / `mengka.` 前缀；**不要用二级子域**（如 api.pet.jwerw.work 无免费证书，会握手失败）
2. **勿动 NS**：续费后别改 NS，否则隧道断
3. **凭据文件保密**：`~/.cloudflared/*.json` 和 `cert.pem` 不要外传（泄露=别人能控制隧道）
4. **到期检查命令**：`nslookup jwerw.work 1.1.1.1` 看 NS 是否是 cloudflare；到期后此命令会异常

---

## 故障排查

| 问题 | 处理 |
|---|---|
| 网站打不开 | 本机 `ipconfig /flushdns`；查隧道进程在不在；`nslookup 域名 1.1.1.1` 看解析 |
| TLS 握手失败 | 大概率是二级子域证书问题，检查是否用了 pet.xxx 格式 |
| 隧道起了但 404 | config.yml 的 hostname 与 CNAME 不一致，检查拼写 |
| 域名到期网页全挂 | 立即续费（NS 不变则自动恢复）；或按方案B换域名重配 |

> 📅 倒数日：2026-10-28 到期，建议 10-21 前处理。
