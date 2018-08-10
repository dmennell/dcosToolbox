#Time Synchronization with DC/OS

DC/OS Masters are very sensitive to their internal clocks being synchronized.  a drift as little as 500ms can mean the differencve between a healthy cluster and an unhealthy one.

##CHRONY v. NTP

By default, Centos and RedHat install with Chrony enabled and NTP disabled.  Even if NTP is installed, CHRONY being installed and running can prevent NTP from running.  As most organizations have access to NTP servers, I prefer NTP.  Below is a process to determine Ensure NTP is Running

Is CHRONY Running? `systemctl status chronyd`
Is NTP Running? `systemctl status chronyd`
Most likely both of them are not

1.  Stop chronyd `systemctl stop chronyd`
2.  Disable chronyd `systemctl disable chronyd`
3.  Start ntp `systemctl disable chrony.service`
4.  Enable NTP `systemctl enable ntpd.service`
5.  View current status of ntpd `ntpq -p`

To force a synchronization of NTP, enter this
`systemctl stop ntpd; ntpd -gq; systemctl start ntpd`

If a clock is too far out of sync, it may not correctly sync.  To ignore a large drift, add `iburst` to the NTP server entries in the `/etc/ntp.conf` like so `time.microsoft.com iburst` 

