#!/usr/bin/env sh
set -e

CONFIG_FILE="/etc/smartdns/smartdns.conf"
OPTIONS_FILE="/data/options.json"
LOG_LEVEL_DEFAULT="info"

# 1. 读取用户在 UI 里设置的 log_level，如果没有则用默认
if [ -f "$OPTIONS_FILE" ]; then
    # 用 jq 提取 options.json 里的 log_level 字段（如果不存在，返回 null）
    LOG_LEVEL="$(jq -r '.log_level // empty' "$OPTIONS_FILE")"
fi
# 若解析后为空或 null，就使用默认
if [ -z "$LOG_LEVEL" ] || [ "$LOG_LEVEL" = "null" ]; then
    LOG_LEVEL="$LOG_LEVEL_DEFAULT"
fi

# 2. 确认配置文件存在且非空
if [ ! -s "$CONFIG_FILE" ]; then
    echo "❗ 错误：未检测到有效的配置文件： $CONFIG_FILE"
    echo "   请先在 /config/addons/local/smartdns/smartdns.conf 编辑后再启动 Add-on。"
    exit 1
fi

# 3. 替换配置文件中的 log-level 行（如果不存在，则追加这一行）
#    假定 smartdns.conf 里某处有形如 "log-level <旧值>" 的行
#    使用 sed 把它替换为当前的字符串 "log-level $LOG_LEVEL"
if grep -qE '^\s*log-level\s+' "$CONFIG_FILE"; then
    sed -i "s/^\s*log-level\s\+.*$/log-level $LOG_LEVEL/" "$CONFIG_FILE"
else
    # 如果找不到 log-level 行，就把它追加到文件末尾
    echo "log-level $LOG_LEVEL" >> "$CONFIG_FILE"
fi

echo "🟢 启动 SmartDNS，加载配置：$CONFIG_FILE，（日志级别: $LOG_LEVEL）"

# 4. 以非守护/前台模式运行 SmartDNS，并将日志输出到控制台
exec /usr/sbin/smartdns \
    -c "$CONFIG_FILE" \
    -f \
    -x
