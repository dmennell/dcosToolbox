# DC/OS 1.11 Prerequisites
Install on all Nodes including Bootstrap, Master, Public Agent and Private Agent Nodes

## SSH into Linux Host
Using your favorite terminal emulator (OSX Terminal, Termius, iTerm, puTTy, etc.)

## Switch to Superuser or Root
```
sudo su -
```

## Copy and paste as 1 large block of text
```
#Stop & Disable Firewall
systemctl stop firewalld && systemctl disable firewalld
#Set SElinux to Permissive
sed -i s/SELINUX=enforcing/SELINUX=permissive/g /etc/selinux/config
set enforce 0
#Create Overlay File System
echo 'overlay' >> /etc/modules-load.d/overlay.conf
modprobe overlay
#Perform OS Updates
yum update -y --exclude=docker-engine,docker-engine-selinux,centos-release* --assumeyes --tolerant
#Install Utility Applications
yum install -y wget curl zip unzip ipset ntp screen bind-utils net-tools net-tools
#Install JQ
wget http://stedolan.github.io/jq/download/linux64/jq
chmod +x ./jq
cp jq /usr/bin
#Add Required Groups
groupadd nogroup
groupadd docker
#Disable ipV6
sed -i -e 's/Defaults    requiretty/#Defaults    requiretty/g' /etc/sudoers
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1
#Stop and Disable DNS Masq
systemctl stop dnsmasq
systemctl disable dnsmasq.service
#Install Docker
echo ">>> Install Docker"
curl -fLsSv --retry 20 -Y 100000 -y 60 -o /tmp/docker-engine-17.05.0.ce-1.el7.centos.x86_64.rpm \
  https://yum.dockerproject.org/repo/main/centos/7/Packages/docker-engine-17.05.0.ce-1.el7.centos.x86_64.rpm
curl -fLsSv --retry 20 -Y 100000 -y 60 -o /tmp/docker-engine-selinux-17.05.0.ce-1.el7.centos.noarch.rpm \
  https://yum.dockerproject.org/repo/main/centos/7/Packages/docker-engine-selinux-17.05.0.ce-1.el7.centos.noarch.rpm
yum -y localinstall /tmp/docker*.rpm || true
systemctl start docker
systemctl enable docker
docker run hello-world
docker info | grep Storage
echo ">>> Update /etc/hosts on boot"

#Update Hosts Fileupdate_hosts_script=/usr/local/sbin/dcos-update-etc-hosts
update_hosts_unit=/etc/systemd/system/dcos-update-etc-hosts.service
mkdir -p "$(dirname $update_hosts_script)"
cat << 'EOF' > "$update_hosts_script"
#!/bin/bash
export PATH=/opt/mesosphere/bin:/sbin:/bin:/usr/sbin:/usr/bin
curl="curl -s -f -m 30 --retry 3"
fqdn=$($curl http://169.254.169.254/latest/meta-data/local-hostname)
ip=$($curl http://169.254.169.254/latest/meta-data/local-ipv4)
echo "Adding $fqdn if $ip is not in /etc/hosts"
grep ^$ip /etc/hosts > /dev/null || echo -e "$ip\t$fqdn ${fqdn%%.*}" >> /etc/hosts
EOF
chmod +x "$update_hosts_script"
cat << EOF > "$update_hosts_unit"
[Unit]
Description=Update /etc/hosts with local FQDN if necessary
After=network.target
[Service]
Restart=no
Type=oneshot
ExecStart=$update_hosts_script
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable $(basename "$update_hosts_unit")
sync
#Wait and Reboot
sleep 4
reboot
```
