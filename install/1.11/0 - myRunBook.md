### Create Base Linux Node
1.  Install CentOS
2.  Add "centos" and "core" user ID's
3.  Add "centos" and "core" to "SUDO" users
4.  Set passwords for centos & core
3.  copy ID from local machine to "centos" & "core"
4.  "visudo" to add user to  
5.  SHUTDOWN and template Node

### Install Prerequisites
6.  Clone VM
7.  Set IP Address & Hostname
8.  Shutdown & Snapshot VM
9.  Install Prerequesites
10. Shutdown and Sanapshot VM
> repeat 6-10 as needed to create nodes
  -External drive Mounted @ /var/lib/mesos/slave

### Set IP Address and Hostname
```
sudo hostnamectl set-hostname dcos233.ishmaelsolutions.com
sudo sed -i 's/.209/.233/g' /etc/sysconfig/network-scripts/ifcfg-eth0
sudo reboot
```

### Populate Hosts File (cattle not pets concept)
```
192.168.1.210 dcos210.ishmaelsolutions.com  dcos210
192.168.1.211 dcos211.ishmaelsolutions.com  dcos211
192.168.1.212 dcos212.ishmaelsolutions.com  dcos212
192.168.1.213 dcos213.ishmaelsolutions.com  dcos213
192.168.1.214 dcos214.ishmaelsolutions.com  dcos214
192.168.1.215 dcos215.ishmaelsolutions.com  dcos215
192.168.1.216 dcos216.ishmaelsolutions.com  dcos216
192.168.1.217 dcos217.ishmaelsolutions.com  dcos217
192.168.1.218 dcos218.ishmaelsolutions.com  dcos218
192.168.1.219 dcos219.ishmaelsolutions.com  dcos219
192.168.1.220 dcos220.ishmaelsolutions.com  dcos220
192.168.1.221 dcos221.ishmaelsolutions.com  dcos221
192.168.1.222 dcos222.ishmaelsolutions.com  dcos222
192.168.1.223 dcos223.ishmaelsolutions.com  dcos223
192.168.1.224 dcos224.ishmaelsolutions.com  dcos224
192.168.1.225 dcos225.ishmaelsolutions.com  dcos225
192.168.1.226 dcos226.ishmaelsolutions.com  dcos226
192.168.1.227 dcos227.ishmaelsolutions.com  dcos227
192.168.1.228 dcos228.ishmaelsolutions.com  dcos228
192.168.1.229 dcos229.ishmaelsolutions.com  dcos229
192.168.1.230 dcos230.ishmaelsolutions.com  dcos230
192.168.1.231 dcos231.ishmaelsolutions.com  dcos231
192.168.1.232 dcos232.ishmaelsolutions.com  dcos232
192.168.1.233 dcos233.ishmaelsolutions.com  dcos233
192.168.1.234 dcos234.ishmaelsolutions.com  dcos234
192.168.1.235 dcos235.ishmaelsolutions.com  dcos235
192.168.1.236 dcos236.ishmaelsolutions.com  dcos236
192.168.1.237 dcos237.ishmaelsolutions.com  dcos237
192.168.1.238 dcos238.ishmaelsolutions.com  dcos238
192.168.1.239 dcos239.ishmaelsolutions.com  dcos239
```
