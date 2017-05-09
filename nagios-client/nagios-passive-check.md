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
dpkg-deb --build nagios-passive-check/ nagios-passive-check_2.4_all.deb
```