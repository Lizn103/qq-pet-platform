# 云端部署（Zeabur / Docker Compose）

把 QQ宠物平台 + 萌卡NT 跑到云端（PaaS），任何设备浏览器访问即用。

## 文件
- `cloud/Dockerfile.mengka`：萌卡NT 容器镜像（官方 Release 自动下载）
- `cloud/docker-compose.cloud.yml`：三件套编排（萌卡 + 平台后端 + 前端）
- 平台自带根目录 `Dockerfile`（backend/frontend 双目标）

## 本机测试
```bash
docker compose -f cloud/docker-compose.cloud.yml up -d --build
```

## Zeabur 部署步骤
1. 在 Zeabur 创建项目 → 服务选「Git」→ 导入本仓库（Lizn103/qq-pet-platform）
2. 首次导入会读到根目录 Dockerfile 与 compose 文件，按提示选服务
3. 为萌卡服务配置持久卷「/opt/mengka/data」；为 backend 配置「/app/data」
4. 生产环境变量：ADMIN_USERNAME / ADMIN_PASSWORD / FRONTEND_ORIGIN
5. 绑定域名：pet.jwerw.work（前端服务）、mengka.jwerw.work（萌卡服务）

## 注意（免费计划限制）
- 免费容器无流量会休眠 → 萌卡可能掉线；建议绑定域名+持续心跳
- 萌卡云签名需联网授权，容器 IP 变化可能触发 QQ 风控
- 需要持久卷存储登录态，否则重启需重新登录
