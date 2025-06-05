############################################################
# 使用 Home Assistant 官方基础镜像（支持多架构：ARM 与 Intel）
############################################################
# Supervisor 会将 BUILD_ARCH 替换为实际架构（例如 armv7、aarch64、amd64 等）
ARG BUILD_ARCH=armv7
FROM ghcr.io/home-assistant/${BUILD_ARCH}-base:latest AS ha-base

LABEL maintainer="you@example.com"
LABEL description="Home Assistant Add-on: SmartDNS v1.2025.03.02-1533（预编译包，自动识别 ARM/Intel）"

# 安装 curl、tar、find 等工具（find 在 BusyBox 内置，无需额外安装）
RUN apk add --no-cache curl tar

# 固定 SmartDNS 版本号，与官方发布包名保持一致
ARG SMARTDNS_VER=1.2025.03.02-1533

# 1. 根据平台自动选择下载链接并解压
RUN set -eux; \
    ARCH="$(uname -m)"; \
    if [ "$ARCH" = "aarch64" ]; then \
        URL="https://github.com/pymumu/smartdns/releases/download/Release46.1/smartdns.${SMARTDNS_VER}.aarch64-linux-all.tar.gz"; \
    elif [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "amd64" ]; then \
        URL="https://github.com/pymumu/smartdns/releases/download/Release46.1/smartdns.${SMARTDNS_VER}.x86_64-linux-all.tar.gz"; \
    elif [ "$ARCH" = "i386" ] || [ "$ARCH" = "i686" ] || [ "$ARCH" = "x86" ]; then \
        URL="https://github.com/pymumu/smartdns/releases/download/Release46.1/smartdns.${SMARTDNS_VER}.x86-linux-all.tar.gz"; \
    else \
        echo "ERROR: 不支持的架构：$ARCH"; exit 1; \
    fi && \
    mkdir -p /tmp/smartdns && \
    curl -fsSL "$URL" | tar -xz -C /tmp/smartdns && \
    \
    # 2. 自动查找解压后目录中的 smartdns 可执行文件并拷贝
    BIN_PATH="$(find /tmp/smartdns -type f -path '*/usr/sbin/smartdns' | head -n1)"; \
    if [ -z "$BIN_PATH" ]; then \
        echo "ERROR: 在 /tmp/smartdns 下未找到 usr/sbin/smartdns，可执行文件路径：$BIN_PATH"; exit 1; \
    fi && \
    cp "$BIN_PATH" /usr/sbin/ && \
    chmod a+rx /usr/sbin/smartdns && \
    rm -rf /tmp/smartdns

# 3. 创建持久化目录：配置与日志
RUN mkdir -p /etc/smartdns /var/log/smartdns

# 4. 拷贝启动脚本与默认配置
COPY run.sh         /usr/bin/run.sh
COPY smartdns.conf  /etc/smartdns/smartdns.conf

# 5. 授予 run.sh 可执行权限，并去除可能的 CRLF
RUN chmod +x /usr/bin/run.sh && \
    sed -i 's/\r$//' /usr/bin/run.sh

# 6. 声明容器暴露的端口（使用 host_network，实际由宿主机监听）
EXPOSE 53/tcp 53/udp

# 7. 容器入口：run.sh
ENTRYPOINT [ "/usr/bin/run.sh" ]
