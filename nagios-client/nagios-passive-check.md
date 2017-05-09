# nagios-passive-check

## Get information from DEB file

```
$ dpkg-deb --info nagios-passive-check_2.3_all.deb
 new debian package, version 2.0.
 size 27040 bytes: control archive=3195 bytes.
     675 bytes,    18 lines   *  changelog            
      75 bytes,     2 lines   *  conffiles            
     360 bytes,    11 lines   *  control              
    1339 bytes,    19 lines   *  md5sums              
    4750 bytes,   186 lines   *  postinst             #!/bin/bash
     766 bytes,    25 lines   *  preinst              #!/bin/bash
 Package: nagios-passive-check
 Version: 2.3
 Section: main
 Priority: optional
 Architecture: all
 Essential: no
 Depends: nagios-plugins, nagios-plugins-basic, nagios-plugins-standard, nsca-client, bc, sysstat, ntp, ntpdate
 Suggests: docbook 
 Maintainer: zollak <info@safenet.hu>
 Replaces: nagios-passive-safenet
 Description: Passive checks solution for SafeNet IT
``` 

## List content of DEB file:

```
$ dpkg-deb --contents nagios-passive-check_2.3_all.deb
drwxr-xr-x root/root         0 2016-02-16 21:49 ./
drwxr-xr-x root/root         0 2016-01-22 14:08 ./usr/
drwxr-xr-x root/root         0 2013-07-25 00:00 ./usr/lib/
drwxr-xr-x root/root         0 2013-07-25 00:00 ./usr/lib/nagios/
drwxr-xr-x root/root         0 2016-02-16 23:35 ./usr/lib/nagios/plugins/
-rwxr-xr-x root/root     12982 2013-07-25 00:00 ./usr/lib/nagios/plugins/check_disk.pl
-rwxr-xr-x root/root      9207 2013-01-21 00:00 ./usr/lib/nagios/plugins/check_mem.pl
-rwxr-xr-x root/root      2274 2016-01-22 14:32 ./usr/lib/nagios/plugins/check_swap_activity
-rwxr-xr-x root/root      3627 2013-07-25 00:00 ./usr/lib/nagios/plugins/check_netstat.pl
-rwxr-xr-x root/root       761 2016-01-19 15:45 ./usr/lib/nagios/plugins/check_uptime
-rwxr-xr-x root/root      7441 2013-07-25 00:00 ./usr/lib/nagios/plugins/check_temp.sh
-rwxr-xr-x root/root      4141 2016-02-02 09:25 ./usr/lib/nagios/plugins/check_raid
-rwxr-xr-x root/root      3407 2015-08-12 00:00 ./usr/lib/nagios/plugins/check_linux_raid.pl
-rwxr-xr-x root/root      3502 2013-07-25 00:00 ./usr/lib/nagios/plugins/check_debupdate.pl
-rwxr-xr-x root/root      5324 2016-02-02 09:25 ./usr/lib/nagios/plugins/check_smart
-rwxr-xr-x root/root      3890 2016-02-02 15:34 ./usr/lib/nagios/plugins/check_ro-mounts
-rwxr-xr-x root/root     12875 2015-03-29 00:00 ./usr/lib/nagios/plugins/check_nfs_health.sh
-rwxr-xr-x root/root      2267 2014-01-27 00:00 ./usr/lib/nagios/plugins/check_disks.sh
-rwxr-xr-x root/root      3179 2015-03-28 00:00 ./usr/lib/nagios/plugins/check_rkhunter.sh
-rwxr-xr-x root/root       779 2016-01-19 21:53 ./usr/lib/nagios/plugins/check_iowait
drwxr-xr-x root/root         0 2016-02-16 22:57 ./usr/bin/
-rwxr-xr-x root/root       579 2016-02-16 22:44 ./usr/bin/nagpassive
drwxr-xr-x root/root         0 2016-02-16 22:31 ./etc/
drwxr-xr-x root/root         0 2016-02-16 22:51 ./etc/cron.d/
-rw-r--r-- root/root         0 2016-01-26 11:14 ./etc/cron.d/nagios-pc
drwxr-xr-x root/root         0 2016-02-16 22:36 ./etc/nagios-passive/
-rw-r--r-- root/root      1650 2016-02-16 22:36 ./etc/nagios-passive/send_nsca.conf
-rw-r--r-- root/root       155 2016-02-16 22:33 ./etc/nagios-passive/nagios-passive.conf
```

## Extract DEB file

```
$ mkdir -p nagios-passive-check/DEBIAN
$ dpkg-deb -x nagios-passive-check_2.3_all.deb nagios-passive-check/
$ dpkg-deb -e nagios-passive-check_2.3_all.deb nagios-passive-check/DEBIAN/
$ tree nagios-passive-check/
nagios-passive-check/
├── DEBIAN
│   ├── changelog
│   ├── conffiles
│   ├── control
│   ├── md5sums
│   ├── postinst
│   └── preinst
├── etc
│   ├── cron.d
│   │   └── nagios-pc
│   └── nagios-passive
│       ├── nagios-passive.conf
│       └── send_nsca.conf
└── usr
    ├── bin
    │   └── nagpassive
    └── lib
        └── nagios
            └── plugins
                ├── check_debupdate.pl
                ├── check_disk.pl
                ├── check_disks.sh
                ├── check_iowait
                ├── check_linux_raid.pl
                ├── check_mem.pl
                ├── check_netstat.pl
                ├── check_nfs_health.sh
                ├── check_raid
                ├── check_rkhunter.sh
                ├── check_ro-mounts
                ├── check_smart
                ├── check_swap_activity
                ├── check_temp.sh
                └── check_uptime

9 directories, 25 files
```

## Rebuild DEB file from source:

```
$ dpkg-deb --build nagios-passive-check/ nagios-passive-check_2.4_all.deb
```

## Edit services manually in /etc/cron.d/[nagios-pc](nagios-pc)

```
###check_procs###
#* * * * * root nagpassive check_procs '-w 171 -c 228' Running_Process

###check_ntp_time###
#* * * * * root nagpassive check_ntp_time '-H europe.pool.ntp.org -w 10 -c 20' NTP_Time

###check_swap_activity###
#* * * * * root nagpassive check_swap_activity '-d 5 -c 8192 -w 4096' Swap_activity

###check_disk###
#* * * * * root nagpassive check_disk '-l -u GB -X tmpfs -X devtmpfs -w 2% -c 1% -A' Disk_Space

############################
#manual
* * * * * root nagpassive check_users '-w 0 -c 3' Current_Users
* * * * * root nagpassive check_dns '-H dev.classbox.me' DNS_Resolution
*/5 * * * * root nagpassive check_apt ' ' Packages
* * * * * root nagpassive check_mysql '-uroot -f /root/.my.cnf' MySQL
* * * * * root nagpassive check_mem.pl '-u -C -w90 -c95' Memory
* * * * * root nagpassive check_http '-H localhost -p 80' HTTP
* * * * * root nagpassive check_http '-S -H localhost -p 443' HTTPS
* * * * * root nagpassive check_ssh '-p 11111 -H localhost' SSH
###check_ntp_time###
* * * * * root nagpassive check_ntp_time '-H 87.229.95.254 -w 10 -c 20' NTP_Time
# Disks_Space Disk_Space and escape chars: \
* * * * * root nagpassive check_disk '-l -u GB -X tmpfs -X devtmpfs -w 2\% -c 1\% -A' Disks_Space
###check_procs###
* * * * * root nagpassive check_procs '-w 235 -c 255' Running_Process
###check_swap_activity###
* * * * * root nagpassive check_swap_activity '-d 5 -c 1536 -w 1024' Swap_activity
```

## List nagios packages after install passive check

```
# dpkg -l | grep nagios
ii  nagios-passive-check            2.3                                 all          Passive checks solution for SafeNet IT
ii  nagios-plugins                  1.5-3ubuntu1                        all          Plugins for nagios compatible monitoring sy                          stems (metapackage)
ii  nagios-plugins-basic            1.5-3ubuntu1                        amd64        Plugins for nagios compatible monitoring sy                          stems
ii  nagios-plugins-common           1.5-3ubuntu1                        amd64        Common files for plugins for nagios compati                          ble monitoring
ii  nagios-plugins-standard         1.5-3ubuntu1                        amd64        Plugins for nagios compatible monitoring sy                          stems
```