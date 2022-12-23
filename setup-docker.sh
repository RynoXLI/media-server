#!/bin/bash -v

# Check if you are root.
if [ "$EUID" -ne 0 ]
  then echo " ❌  Please run as root"
  exit 1
fi

# set environment variables
export $(grep -v '^#' .env | xargs -d '\n')

# Distrib RHEL
if [ -x "$(command -v dnf)" ]; then
    yum update -y
    yum install -y yum-utils curl wget httpd-tools
    yum-config-manager --add-repo "https://download.docker.com/linux/centos/docker-ce.repo"
    yum makecache
    yum install -y docker-ce docker-ce-cli containerd.io
    curl -s https://api.github.com/repos/docker/compose/releases/latest | grep browser_download_url  | grep docker-compose-linux-x86_64 | cut -d '"' -f 4 | wget -qi -
    chmod +x docker-compose-linux-x86_64
    mv docker-compose-linux-x86_64 /usr/local/bin/docker-compose
    ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Distrib Debian / Ubuntu
elif [ -x "$(command -v apt-get)" ]; then
    apt update && apt upgrade -y
    apt install -y curl apt-transport-https ca-certificates gnupg2 software-properties-common apache2-utils
    curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable"
    apt-get update -y
    apt-get -y install docker-ce docker-compose

else
    echo "❌  This script is not compatible with your system"
    exit 1
fi

if [ -x "$(firewall-cmd --version)" ]; then
    firewall-cmd --add-port=80/tcp --permanent
    firewall-cmd --add-port=443/tcp --permanent
    firewall-cmd --reload
fi

systemctl enable docker
systemctl start docker

docker network create ${NETWORK}