# Time Synchronization with DC/OS

DC/OS Masters are very sensitive to their internal clocks being synchronized.  Drift as little as 500ms can mean the difference between a healthy cluster and an unhealthy one.  NTP is the prefered method of synchronizing time clocks.

## Is NTP Installed and Running?
The below steps check whether NTP is installed and running.

### Check to see whether or not NTP is installed:
```
$ chkconfig --list ntpd
```
If installed and enabled, you should get a response similar to the following:
```
ntpd           	0:off	1:off	2:on	3:on	4:on	5:on	6:off
```
If not, there are many blogs on the Internet that describe how to install NTP.  Here is one:
```
http://www.tecmint.com/install-ntp-server-in-centos/
```
### Check to see whether or not NTP is running:
```
$ ntpq -p
```
If NTP is runing, you should get a response similar to the following:
```
     remote           refid      st t when poll reach   delay   offset  jitter
==============================================================================
+clock.util.phx2 .CDMA.           1 u  111  128  377  175.495    3.076   2.250
*clock02.util.ph .CDMA.           1 u   69  128  377  175.357    7.641   3.671
 ms21.snowflakeh .STEP.          16 u    - 1024    0    0.000    0.000   0.000
 rs11.lvs.iif.hu .STEP.          16 u    - 1024    0    0.000    0.000   0.000
 2001:470:28:bde .STEP.          16 u    - 1024    0    0.000    0.000   0.000
```

Here are some other commants that can be used to check NTP status:
```
ntptime
adjtimex -p
timedatectl
```

## Install NTP
There are many examples on the Internet on how to install NTP.  Here is one:


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
1.  Stop chronyd `$ systemctl stop chronyd`
2.  Disable chronyd `$ systemctl disable chronyd`
3.  Start ntp `$ systemctl disable chrony.service`
4.  Enable NTP `$ systemctl enable ntpd.service`
5.  View current status of ntpd `$ ntpq -p`

## Force NTP Synchronization
To force a synchronization of NTP, enter this:
```
$ systemctl stop ntpd; ntpd -gq; systemctl start ntpd
```

## Dealing With Large Drift
If a clock is too far out of sync, it may not correctly synchronize with the NTP server.  To configure NTP to ignore a large drift, do the following:
1.  Add `iburst` to the NTP server entries in the `/etc/ntp.conf` like so `time.microsoft.com iburst`.  
2.  Restart NTP `$ systemctl restart ntpd`

