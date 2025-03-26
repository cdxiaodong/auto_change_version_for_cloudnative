# auto_change_version_for_cloudnative
change_docker.sh 是一个 Bash 脚本，用于在 Linux 系统上管理和切换 Docker 版本。脚本从 Docker 官方网站（https://download.docker.com/linux/static/stable/x86_64/）下载指定版本的 Docker 二进制文件，并自动安装到系统中。它支持列出所有可用版本、切换到指定版本，并在必要时自动配置 Docker 服务文件（docker.service）。该工具适用于需要快速测试不同 Docker 版本或在没有完整 Docker 安装的系统上部署特定版本的用户。
