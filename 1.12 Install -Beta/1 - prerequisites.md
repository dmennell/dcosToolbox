# Enterprise DC/OS 1.12 Prerequisites Installation Guide

## Prepare Node

### Allow SUDO commands to run without password
```
sudo visudo
```
scroll down and remove the `#` from the line that specifies whether or not to require password when running `sudo` commands

### Update Centos to 7.5 If Necessary
```
sudo cat /etc/redhat-release
sudo yum check-update
sudo yum update -y
sudo reboot
cat /etc/redhat-release
```

### Install Utility/Helper Applications
```
sudo yum install -y yum-utils xz bash net-utils bind-utils coreutils gawk gettext grep iproute util-linux curl ipset sed wget net-tools unzip
```

### Install and Configure NTP
```
sudo yum remove -y chrony
sudo yum install -y ntp
sudo systemctl enable ntpd
sudo systemctl start ntpd
sudo timedatectl set-ntp 1
```

### Install JQ
```
sudo wget http://stedolan.github.io/jq/download/linux64/jq
sudo chmod +x ./jq
sudo cp jq /usr/bin
```

### Disable ipV6 (This section suspect)
```
sudo sed -i -e 's/Defaults    requiretty/#Defaults    requiretty/g' /etc/sudoers
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
```

### Stop # Disable "firewalld"
```
sudo systemctl stop firewalld && sudo systemctl disable firewalld
```

### Stop # Disable "dnsmasq"
```
sudo systemctl stop dnsmasq && sudo systemctl disable dnsmasq.service
```

### Set SE Linux to Permissive
```
sudo sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
```

### Add Groups
```
sudo groupadd nogroup &&
sudo groupadd docker
```

### Set Locale
```
sudo localectl set-locale LANG=en_US.utf8
```

### Reboot
```
sudo reboot
```

### Install, Start, and Enable Docker CE with OverlayFS on CentOS/RedHat
```
sudo echo 'overlay' >> /etc/modules-load.d/overlay.conf
sudo modprobe overlay

sudo yum update --exclude=docker-engine,docker-engine-selinux,centos-release* --assumeyes --tolerant

sudo yum remove docker docker-common docker-selinux docker-engine

sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

sudo yum list docker-ce --showduplicates | sort -r

sudo yum install docker-ce

sudo systemctl start docker
sudo systemctl enable docker

sudo docker pull nginx
sudo docker ps
```

### Reboot Again
```
sudo reboot
```
