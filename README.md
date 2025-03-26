# auto_change_version_for_cloudnative
# Docker Version Switcher

`change_docker.sh` 是一个轻量级的 Bash 脚本，用于在 Linux 系统上管理和切换 Docker 版本。它可以从 Docker 官方网站下载 Docker 二进制文件，安装指定版本，并确保 Docker 服务正常运行。脚本特别适合开发人员、测试人员或系统管理员在需要特定 Docker 版本时快速切换。



## 功能

- **列出可用版本**：显示 Docker 官方网站上所有可用的稳定版本。
- **切换 Docker 版本**：下载并安装用户指定的 Docker 版本。
- **自动配置服务**：在安装时检测并创建 `docker.service`（如果系统中不存在），确保 Docker 服务可以通过 `systemctl` 管理。
- **无需预装 Docker**：即使系统中未安装 Docker，也可以直接使用脚本部署指定版本。
![image](https://github.com/user-attachments/assets/47a3675f-0165-44fe-b0cb-8cf4f3f332a7)


![image](https://github.com/user-attachments/assets/82d0c44c-d9b1-43ae-89c8-7e95c62d3530)


## 前提条件

- **操作系统**：基于 Linux 的系统（推荐 Ubuntu、Debian 等使用 systemd 的发行版）。
- **依赖工具**：
  - `curl`：用于下载文件。
  - `tar`：用于解压 `.tgz` 文件。
  - `systemctl`：用于管理 Docker 服务（可选，脚本会自动检测）。
- **权限**：需要 root 权限运行脚本。
- **网络**：需要访问 `https://download.docker.com`。

安装依赖（以 Ubuntu 为例）：
```bash
sudo apt update
sudo apt install -y curl tar
