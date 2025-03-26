#!/bin/bash

# 检查是否以 root 权限运行
if [ "$(id -u)" -ne 0 ]; then
    echo "此脚本必须以root权限运行"
    exit 1
fi

# 获取当前 Docker 版本（如果已安装）
get_current_docker_version() {
    if command -v docker &> /dev/null; then
        docker --version | cut -d ' ' -f 3 | cut -d ',' -f 1
    else
        echo "未检测到 Docker"
    fi
}

# 获取可用 Docker 版本列表
get_available_versions() {
    url="https://download.docker.com/linux/static/stable/x86_64/"
    html=$(curl -s "$url")
    if [ -z "$html" ]; then
        echo "错误: 无法获取可用版本列表。"
        exit 1
    fi
    echo "$html" | grep -oP '(?<=docker-)[0-9]+\.[0-9]+\.[0-9]+(?=\.tgz)' | sort -u
}

# 创建 docker.service 文件（如果不存在）
create_docker_service() {
    if [ ! -f "/lib/systemd/system/docker.service" ]; then
        echo "未找到 docker.service，正在创建..."
        cat <<EOF | sudo tee /lib/systemd/system/docker.service > /dev/null
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target

[Service]
Type=notify
ExecStart=/usr/bin/dockerd
ExecReload=/bin/kill -s HUP \$MAINPID
TimeoutStartSec=0
RestartSec=2
Restart=always
StartLimitBurst=3
StartLimitInterval=60s
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
Delegate=yes
KillMode=process

[Install]
WantedBy=multi-user.target
EOF
        sudo systemctl daemon-reload
        echo "docker.service 已创建并加载"
    else
        echo "docker.service 已存在，无需创建"
    fi
}

# 安装指定 Docker 版本
install_docker_version() {
    version=$1
    url="https://download.docker.com/linux/static/stable/x86_64/docker-$version.tgz"
    echo "正在下载Docker版本 $version..."
    curl -L -o "docker-$version.tgz" "$url" || { echo "下载失败"; exit 1; }
    echo "正在解压..."
    tar -xzf "docker-$version.tgz" || { echo "解压失败"; exit 1; }
    echo "正在停止Docker服务（如果正在运行）..."
    systemctl stop docker 2>/dev/null || true
    echo "正在安装新的Docker二进制文件..."
    cp -f docker/* /usr/bin/ || { echo "安装失败"; exit 1; }
    echo "检测并配置Docker服务..."
    create_docker_service
    echo "正在启动Docker服务..."
    systemctl start docker || { echo "启动Docker服务失败"; exit 1; }
    echo "成功安装Docker版本 $version"
    # 清理临时文件
    rm -f "docker-$version.tgz"
    rm -rf docker
}

# 初始化参数变量
list=false
version=""

# 解析命令行参数
while [ "$#" -gt 0 ]; do
    case "$1" in
        --list|-l)
            list=true
            shift
            ;;
        --version|-v)
            version="$2"
            shift 2
            ;;
        *)
            echo "未知参数: $1"
            exit 1
            ;;
    esac
done

# 获取当前版本和可用版本
current_version=$(get_current_docker_version)
available_versions=$(get_available_versions)

# 根据参数执行操作
if [ "$list" = true ]; then
    if [ -z "$available_versions" ]; then
        echo "错误: 无法获取可用版本列表。"
    else
        echo "可用Docker版本:"
        echo "$available_versions"
    fi
elif [ -n "$version" ]; then
    if [ -z "$available_versions" ]; then
        echo "错误: 无法获取可用版本列表。"
    elif echo "$available_versions" | grep -q "^$version$"; then
        install_docker_version "$version"
    else
        echo "版本 $version 不可用"
    fi
else
    echo "当前Docker版本: $current_version"
    echo "使用 --list 查看可用版本"
    echo "使用 --version <版本号> 切换到指定版本"
fi
