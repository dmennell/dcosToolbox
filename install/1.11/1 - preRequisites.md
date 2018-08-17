# DC/OS 1.11 Prerequisites
This doc provides 2 sets of instructions to install the prerequisites required for DC/OS 1.11 Install.  the first set is a commented "1-at-a-time" process.  The second is a 1-shot scropt that you can copy, paste, and execute in 1 step once you are comfortable with the process.  This process has been tested on CentOS 7.  RHEL may require a different process to install and enable Docker.

# Step-By-Step Prerequisite Installation Process

Disable Sudo Passwords
```
sudo visudo
```
then remove the `#` from the line following `## Same thing without a password` so that it reads `%wheel  ALL=(ALL)       NOPASSWD: ALL`

Swith to SupeUser Role
```
sudo su -
```

Stop & Disable Firewall
```
systemctl stop firewalld && systemctl disable firewalld
```

Set SElinux to Permissive
```
sed -i s/SELINUX=enforcing/SELINUX=permissive/g /etc/selinux/config
set enforce 0
```

Create Overlay File System
```
echo 'overlay' >> /etc/modules-load.d/overlay.conf
modprobe overlay
```

Perform OS Updates
```
yum update -y --exclude=docker-engine,docker-engine-selinux,centos-release* --assumeyes --tolerant
```

Install Utility Applications
```
yum install -y wget curl zip unzip ipset ntp screen bind-utils net-tools
```

Install JQ
```
wget http://stedolan.github.io/jq/download/linux64/jq
chmod +x ./jq
cp jq /usr/bin
```

Add Required Groups
```
groupadd nogroup
groupadd docker
```

Disable ipV6
```
sed -i -e 's/Defaults    requiretty/#Defaults    requiretty/g' /etc/sudoers
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1
```

Stop and Disable DNS Masq
```
systemctl stop dnsmasq
systemctl disable dnsmasq.service
```

Install Docker
```
#echo ">>> Install Docker"
curl -fLsSv --retry 20 -Y 100000 -y 60 -o /tmp/docker-engine-17.06.2.ce-1.el7.centos.x86_64.rpm \
  https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-17.06.2.ce-1.el7.centos.x86_64.rpm
yum -y localinstall /tmp/docker*.rpm || true
systemctl start docker
systemctl enable docker
docker run hello-world
docker info | grep Storage
```

Update Hosts File
```
echo ">>> Update /etc/hosts on boot"
Update Hosts Fileupdate_hosts_script=/usr/local/sbin/dcos-update-etc-hosts
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
```

Reboot
```
sudo reboot
```

# Individual To Each Cluster Node

Deploy regionZone Identifier File & Modify Accordingly (Master, Public, Private)

Deploy Attributes File

