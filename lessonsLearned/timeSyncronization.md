# Time Synchronization with DC/OS

DC/OS Masters are very sensitive to their internal clocks being synchronized.  Drift as little as 500ms can mean the difference between a healthy cluster and an unhealthy one.  NTP is the prefered method of synchronizing time clocks.

## Is NTP Running
Enter one of the following commands to determine whether NTP is running:
```
ntptime
adjtimex -p
timedatectl
```

## Install NTP
There are many examples on the Internet on how to install NTP.  Here is one:
```
http://www.tecmint.com/install-ntp-server-in-centos/
```

## Synchronize Hardware & Software CLocks
To synchronize the hardware and software clocks of your server, run the following:
```
hwclock -w
```

## CHRONY v. NTP
By default, Centos and RedHat install with Chrony enabled.  Even if NTP is installed, CHRONY being installed and running can prevent NTP from running.  As most organizations have access to NTP servers, I prefer NTP.  Below is a process to determine Ensure NTP is Running

Is CHRONY Running? `systemctl status chronyd`
Is NTP Running? `systemctl status chronyd`
Most likely both of them are not.

Follow the below instructions to disable chrony and enable NTP
1.  Stop chronyd `systemctl stop chronyd`
2.  Disable chronyd `systemctl disable chronyd`
3.  Start ntp `systemctl disable chrony.service`
4.  Enable NTP `systemctl enable ntpd.service`
5.  View current status of ntpd `ntpq -p`

## Force NTP Synchronization
To force a synchronization of NTP, enter this:
```
systemctl stop ntpd; ntpd -gq; systemctl start ntpd
```

## Dealing With Large Drift
If a clock is too far out of sync, it may not correctly synchronize with the NTP server.  To configure NTP to ignore a large drift, do the following:
1.  Add `iburst` to the NTP server entries in the `/etc/ntp.conf` like so `time.microsoft.com iburst`.  
2.  Restart NTP `systemctl restart ntpd`

