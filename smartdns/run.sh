#!/usr/bin/env sh
set -e

CONFIG_FILE="/etc/smartdns/smartdns.conf"

# 检查配置文件是否存在且非空
if [ ! -f "$CONFIG_FILE" ] || [ ! -s "$CONFIG_FILE" ]; then
    echo "❗ 错误：未检测到有效的配置文件：$CONFIG_FILE"
    echo "   请先在 /config/addons/local/smartdns/smartdns.conf 编辑后再启动 Add-on。"
    exit 1
fi

echo "🟢 启动 SmartDNS，加载配置：$CONFIG_FILE"

# 以非守护模式运行，让 Supervisor 捕获日志
exec /usr/sbin/smartdns \
    -c "$CONFIG_FILE" \
    -f \
    -x