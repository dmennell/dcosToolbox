# Create Local Time Server on Bootstrap Node
At times, you may need to set up a local NTP server for time synchronization.  Example might be if you wish to "Airgap" the cluster, or the cluster does not have access to time servers for synchronization.  Here are a few short steps to setting up an NTP Server on your Bootstrap Node

## On Bootstrap Server (Time Server)

#### Switch to Super User Account
```
sudo su
```

#### Install NTP Server and Remove CHRONYD
```
yum install ntp
yum remove chronyd
yum enable ntpd
```

#### Allow Clients on Local Subnet to access NTP Server
This example assumes a subnet of 172.12.0.0/16.  Please modify the below steps to fit the subnet of your environment
```
echo -e '\nrestrict 172.12.0.0 mask 255.255.0.0 nomodify notrap\n' | sudo tee -a /etc/ntp.conf
systemctl restart ntpd
```

## On All Cluster Nodes (Masters & Agents)  
This example was created for RHEL systems that use CHRONYD for time synchronization purposes.  Please modify as necessary for systems that are using NTPD for time synchronization.

#### Switch to Super User Account
```
sudo su
```

#### Delete Old Entries and Add The Bootstrap As Time Server
This example add the local Bootstrap node as the time server (172.12.0.81) and and removes the AWS time server (169.254.169.123).  Please modify to fit your environment.  The /etc/chrony.conf file can be modified by hand using VI or your favorite text editor as well.
```
sed -i '/^server/d' /etc/chrony.conf
echo -e '\nserver 172.12.0.81 iburst\nserver 169.254.169.123 iburst\n' | sudo tee -a /etc/chrony.conf
```

#### Restart CHRONYD
```
systemctl restart chronyd
```
