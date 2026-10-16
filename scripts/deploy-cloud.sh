#!/bin/bash
# ============================================================
# QQ宠物平台 + 萌卡NT 云服务器一键部署脚本 (Ubuntu/Debian)
# 用法: 把以下文件放到同一目录后  sudo bash deploy-cloud.sh
#   1. mengka-pet-1.0.1-linux-amd64.tar.gz (平台)
#   2. mengka-nt-2.7.2-linux-amd64.tar.gz  (萌卡)
# 运行后: 平台:2345/前端:5173? 萌卡:7878/7879
# 隧道: 用已购买的域名+Cloudflare (见教程10) 或临时trycloudflare
# ============================================================
set -e
echo "==> [1/8] 检查环境"
apt-get update -qq
apt-get install -y -qq curl wget tar python3 unzip net-tools >/dev/null 2>&1 || true

echo "==> [2/8] 安装平台到 /opt/qqpet"
mkdir -p /opt/qqpet /opt/qqpet/data /opt/mengka
tar xzf mengka-pet-1.0.1-linux-amd64.tar.gz -C /opt/qqpet --strip-components=1 2>/dev/null || tar xzf mengka-pet-1.0.1-linux-amd64.tar.gz -C /opt/qqpet

echo "==> [3/8] 安装萌卡到 /opt/mengka"
tar xzf mengka-nt-2.7.2-linux-amd64.tar.gz -C /opt/mengka --strip-components=1 2>/dev/null || tar xzf mengka-nt-2.7.2-linux-amd64.tar.gz -C /opt/mengka

echo "==> [4/8] 启动萌卡"
nohup /opt/mengka/mengka-nt > /var/log/mengka.log 2>&1 &
sleep 8
echo "    萌卡管理台: http://$(hostname -I | awk '{print $1}'):7878"

echo "==> [5/8] 启动平台"
cd /opt/qqpet
nohup ./qq-pet-server > /var/log/qqpet-server.log 2>&1 &
nohup ./qq-pet-frontend > /var/log/qqpet-frontend.log 2>&1 &
sleep 5
echo "    平台: http://$(hostname -I | awk '{print $1}'):5173"

echo "==> [6/8] 开机自启 (systemd)"
cat > /etc/systemd/system/qqpet.service <<'EOF'
[Unit]
Description=QQ Pet platform + Mengka
After=network.target
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash /opt/qqpet/start-all.sh
ExecStop=/bin/bash /opt/qqpet/stop-all.sh
[Install]
WantedBy=multi-user.target
EOF
cat > /opt/qqpet/start-all.sh <<'EOF'
#!/bin/bash
nohup /opt/mengka/mengka-nt > /var/log/mengka.log 2>&1 &
sleep 6
cd /opt/qqpet && nohup ./qq-pet-server > /var/log/qqpet-server.log 2>&1 &
cd /opt/qqpet && nohup ./qq-pet-frontend > /var/log/qqpet-frontend.log 2>&1 &
exit 0
EOF
cat > /opt/qqpet/stop-all.sh <<'EOF'
#!/bin/bash
pkill -f mengka-nt || true
pkill -f qq-pet-server || true
pkill -f qq-pet-frontend || true
exit 0
EOF
chmod +x /opt/qqpet/start-all.sh /opt/qqpet/stop-all.sh
systemctl daemon-reload
systemctl enable qqpet >/dev/null 2>&1 || true

echo "==> [7/8] 隧道 (二选一: 固定域名/临时)"
read -p "有固定域名+Cloudflare? [y/N]: " use_domain
if [ "$use_domain" = "y" ] || [ "$use_domain" = "Y" ]; then
    echo "请按教程10操作: cloudflared tunnel login + create + route dns"
    echo "提示命令已输出到 /root/cloudflare-setup.txt"
    cat > /root/cloudflare-setup.txt <<'EOF'
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared
chmod +x /usr/local/bin/cloudflared
cloudflared tunnel login
cloudflared tunnel create qqpet-main
cloudflared tunnel route dns qqpet-main pet.jwerw.work
cloudflared tunnel route dns qqpet-main mengka.jwerw.work
# config.yml 写到 ~/.cloudflared/config.yml (模板见仓库教程10)
cloudflared tunnel run qqpet-main
EOF
else
    echo "用临时隧道（重启会变）:"
    nohup curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared &
fi

echo "==> [8/8] 完成! 开放端口"
ufw allow 7878/tcp 2>/dev/null || true
ufw allow 5173/tcp 2>/dev/null || true
ufw disable 2>/dev/null || true
echo "============================================="
echo " 萌卡管理台: http://IP:7878  (初始化设管理员)"
echo " 平台前端:   http://IP:5173  (需要平台admin)"
echo " 平台API:    http://IP:2345"
echo " 上线前先: 萌卡登录QQ + 平台配萌卡节点(7879+令牌)"
echo "============================================="