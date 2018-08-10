# Time Synchronization with DC/OS

DC/OS Masters are very sensitive to their internal clocks being synchronized.  a drift as little as 500ms can mean the differencve between a healthy cluster and an unhealthy one.  NTP is the prefered method of synchronizing time clocks

## Install and Enable NTP for DC/OS
If you do not have NTP installed, follow the below process.  If you have local NTP servers, use those instead of the Internet ones.


## CHRONY v. NTP

By default, Centos and RedHat install with Chrony enabled and NTP disabled.  Even if NTP is installed, CHRONY being installed and running can prevent NTP from running.  As most organizations have access to NTP servers, I prefer NTP.  Below is a process to determine Ensure NTP is Running

Is CHRONY Running? `systemctl status chronyd`
Is NTP Running? `systemctl status chronyd`
Most likely both of them are not.

Follow the below instructions to disable chrony and enable ntp.

1.  Stop chronyd `systemctl stop chronyd`
2.  Disable chronyd `systemctl disable chronyd`
3.  Start ntp `systemctl disable chrony.service`
4.  Enable NTP `systemctl enable ntpd.service`
5.  View current status of ntpd `ntpq -p`

## Force NTP Synchronization
To force a synchronization of NTP, enter this `systemctl stop ntpd; ntpd -gq; systemctl start ntpd`

## Dealing With Large Drift
If a clock is too far out of sync, it may not correctly synchronize with the NTP server.  To configure NTP to ignore a large drift, do the following:
1.  Add `iburst` to the NTP server entries in the `/etc/ntp.conf` like so `time.microsoft.com iburst`.  
2.  Restart NTP `systemctl restart ntpd`

