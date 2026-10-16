# 安装指南 / Install Guide

## Windows 一键安装

1. 构建产物（在有 Go 1.26+ 与 Node 20+ 的机器上）：
   ```
   scripts\build-backend.bat
   scripts\build-frontend.bat
   ```
   产物输出到 `build/qq-pet-server.exe` 与 `build/qq-pet-frontend.exe`。

2. 下载 NSSM (https://nssm.cc/download)，把 `nssm.exe` 放进 `deploy/`。

3. 右键管理员运行 `deploy\windows-installer.bat`。
   - 安装目录：`%ProgramFiles%\QQ Pet`
   - 注册两个 Windows 服务：QQPetServer / QQPetFrontend
   - 端口：后端 2345、前端 5173、萌卡管理台 7878、插件 7879

4. 首次启动后端会要求设置监听端口与管理员账号密码。

## Docker

```bash
docker compose up -d --build
```

## 首次使用

1. 打开 http://localhost:5173 注册/登录
2. 管理端 → 萌卡/机器人节点配置：host=127.0.0.1, port=<萌卡插件WS端口>, token=<萌卡插件服务令牌>
3. 「账号管理」添加 QQ 账号并登录

## 常见问题

- **添加账号提示服务器暂时不可用**：平台与萌卡插件通道断开。修复方式：管理端 → 萌卡节点 → 重新连接；或使用仓库自带的隧道守护脚本自动重连。
- **端口被占用**：修改前端环境变量 FRONTEND_PORT / 后端初始化端口。
