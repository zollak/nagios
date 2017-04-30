# Install Nagios server to own VPS (Ubuntu)

## Network settings

```bash
cat /etc/network/interfaces
```

```
# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
iface eth0 inet static
        address 107.170.80.72
        netmask 255.255.240.0
        gateway 107.170.80.1
        dns-nameservers 8.8.4.4 8.8.8.8 209.244.0.3
```

## Set users

Set password for root user (first time we logged in with root):
```bash
passwd
```

Add new user:
```bash
adduser zollak
```

Set user rights:
```bash
usermod -aG sudo zollak
id zollak
```

Change user from root to zollak:
```bash
su - zollak
```

## Set SSH public key on the server

1. Generate RSA key's on your computer
	- with [putty](TODO)
	- with [openssh](TODO)

2. Create SSH folder:

```bash
mkdir ~/.ssh
chmod 0700 ~/.ssh
touch ~/.ssh/authorized_keys
chmod 0600 ~/.ssh/authorized_keys
```

3. Paste the SSH public key into your **~/.ssh/authorized_keys** file (Your key should start with "ssh-rsa AAAA ...."):

```bash
vi ~/.ssh/authorized_keys
```
4. tap the i key on your keyboard & SHIFT+Ctr+V to paste in linux console, on Windows right-click your mouse to paste.
5. To save, tap the following keys on your keyboard (in this order): Esc, :, w, q, Enter.

## Secure SSH service

Once you have verified that your key-based logins are working, you may elect to disable username/password logins to achieve better security. To do this, you need to edit your SSH server's configuration file. On Debian/ Ubuntu systems, this file is located at /etc/ssh/sshd_config. 

```bash
sudo vi /etc/ssh/sshd_config
```

Edit the lines, referenced below: 
```
Port 15951
ListenAddress 0.0.0.0
PermitRootLogin no
PasswordAuthentication no
UsePAM no
AllowUsers zollak
```

Now, reload the SSH server's configuration:
```bash
sudo reload ssh
netstat –nltp
service sshd status
```

## Environment settings

```bash
vi ~/.bashrc
```
[.bashrc](../.bashrc)

## Set configuration management

```
sudo dpkg-reconfigure debconf
```
Dialog/low

## Disable IPv6

```
sudo echo net.ipv6.conf.all.disable_ipv6=1 > /etc/sysctl.d/disableipv6.conf
sudo reboot
```

## Time zone

```bash
date
sudo apt-get install ntpdate
sudo mv /etc/localtime /etc/localtime-old
sudo ln -sf /usr/share/zoneinfo/Europe/Budapest /etc/localtime
sudo echo 'Europe/Budapest' > /etc/timezone
date
```
## Sendmail

```bash
sudo apt-get install sendmail
```

```bash
sudo vi /etc/mail/sendmail.mc
```
```
dnl # Masquerading options
FEATURE(`always_add_domain')dnl
MASQUERADE_AS(`nagios.example.com')dnl
FEATURE(`allmasquerade')dnl
FEATURE(`masquerade_envelope')dnl
```

In this case server name should be nagios.example.com...

/etc/init.d/sendmail restart

## Automatic update

Install service
```bash
sudo apt-get install unattended-upgrades
```
Set unattended upgrades in /etc/apt/apt.conf.d/[50unattended-upgrades](50unattended-upgrades)

```bash
sudo vi /etc/apt/apt.conf.d/50unattended-upgrades
```

If you already installed may you need to reconfigure to enable it:
```bash
sudo dpkg-reconfigure -plow unattended-upgrades
```
Set **Yes**!

If you want to turn off:
```
vi /etc/apt/apt.conf.d/20auto-upgrades
```

## Fail2ban

```bash
apt-get install fail2ban
```
Howto:

https://www.digitalocean.com/community/articles/how-to-protect-ssh-with-fail2ban-on-ubuntu-12-04

http://hup.hu/node/130645 

http://www.fail2ban.org/wiki/index.php/Fail2ban:Community_Portal

Create /etc/fail2ban/action.d/[iptables-multiport-permanent.conf](iptables-multiport-permanent.conf) file.
```bash
vi /etc/fail2ban/action.d/iptables-multiport-permanent.conf
```
This script save banned IP-'s to /etc/fail2ban/permanent_xxxxx_ban.conf files. After restart fail2ban service this script will read banned IP's from these files.

Create /etc/fail2ban/[jail.local](jail.local) file.
```bash
vi /etc/fail2ban/jail.local
```

Check filters:
```bash
sudo fail2ban-regex /var/log/apache2/error.log /etc/fail2ban/filter.d/apache-auth.conf
sudo fail2ban-regex /var/log/apache2/error.log /etc/fail2ban/filter.d/apache-noscript.conf
sudo fail2ban-regex /var/log/apache2/error.log /etc/fail2ban/filter.d/apache-overflows.conf
```
Restart fail2ban service:
```bash
service fail2ban restart
iptables -L
```

## Rkhunter

Install:
```bash
sudo apt-get install rkhunter
```

Basic check:
```bash
sudo rkhunter -c
```

```bash
sudo vi /etc/default/rkhunter
```

```
CRON_DAILY_RUN="true"
CRON_DB_UPDATE="true"
DB_UPDATE_EMAIL="false"
REPORT_EMAIL="admin@example.com"
APT_AUTOGEN="true"
NICE="0"
RUN_CHECK_ON_BATTERY="false"
```

Create /etc/[rkhunter.conf.local](rkhunter.conf.local)
```
sudo vi /etc/rkhunter.conf.local
```
? TODO
#az alábbi alapból be volt kapcsolva, ezért ha a local file-ban kikapcsolom, nem lesz kikapcsolva!
#DISABLE_TESTS="suspscan hidden_procs deleted_files packet_cap_apps apps"
#DISABLE_TESTS="deleted_files"
ALLOWPROCLISTEN="/usr/sbin/snort"
MAIL-ON-WARNING="admin@example.com"


Update database if we know what was the reason of the modification:
```
sudo rkhunter --propupdate
```

## Logwatch
https://www.digitalocean.com/community/tutorials/how-to-install-and-use-logwatch-log-analyzer-and-reporter-on-a-vps

```bash
apt-get install logwatch
less /usr/share/logwatch/default.conf/logwatch.conf
logwatch --detail Low --service All --range today
grep -r logwatch /etc/cron*
```

```
/etc/cron.daily/00logwatch:test -x /usr/share/logwatch/scripts/logwatch.pl || exit 0
/etc/cron.daily/00logwatch:/usr/sbin/logwatch --output mail
```
? TODO
```bash
vi /etc/cron.daily/00logwatch
```

## NAGIOS

apt-get install nagios3 nagios-nrpe-plugin

NAGIOS apache: nagiosadmin
pwd: KeePass

Create objects dir
mkdir /etc/nagios3/objects

Create own host as /etc/nagios3/objects/[nagios.example.com.cfg](nagios.example.com.cfg)

vi /etc/nagios3/objects/nagios.example.com.cfg

nagios3 -v /etc/nagios3/nagios.cfg
/etc/init.d/nagios3 restart


vi /etc/nagios3/nagios.cfg
cfg_dir=/etc/nagios3/objects
check_external_commands=1

vi /etc/apache2/ports.conf
NameVirtualHost *:40000
Listen 40000

/etc/init.d/apache2 restart

http://107.170.80.72:40000/nagios3/
nagiosadmin
KeePass




dpkg --get-selections | grep nagios
nagios-images                                   install
nagios-nrpe-plugin                              install
nagios-passive-safenet                          install
nagios-plugins                                  install
nagios-plugins-basic                            install
nagios-plugins-common                           install
nagios-plugins-standard                         install
nagios3                                         install
nagios3-cgi                                     install
nagios3-common                                  install
nagios3-core                                    install




Nagiosban be kell állítani,h kinek megy az összes értesítés:

Modify /etc/nagios3/conf.d/[contacts_nagios2.cfg](contacts_nagios2.cfg)

vi /etc/nagios3/conf.d/contacts_nagios2.cfg

vi /etc/nagios3/nagios.cfg
#admin_email=root@localhost
admin_email=admin@example.com

/etc/init.d/nagios3 restart



Send this host info to another nagios server (if we have secondary nagios server)
apt-get install nagios-nrpe-server

...

## Security

### Apache signature

vi /etc/apache2/apache2.conf

TraceEnable off
ServerTokens Prod
ServerSignature off

/etc/init.d/apache2 restart

### PHP signature

vi /etc/php5/apache2/php.ini
vi /etc/php5/cli/php.ini

expose_php = Off

/etc/init.d/apache2 restart

### Apache SSL

```bash
apache2ctl -S
```
```
VirtualHost configuration:
*:40004                nagios.example.com (/etc/apache2/sites-enabled/ssl.conf:4)
ServerRoot: "/etc/apache2"
Main DocumentRoot: "/var/www"
Main ErrorLog: "/var/log/apache2/error.log"
Mutex mpm-accept: using_defaults
Mutex watchdog-callback: using_defaults
Mutex rewrite-map: using_defaults
Mutex ssl-stapling: using_defaults
Mutex ssl-cache: using_defaults
Mutex default: dir="/var/lock/apache2" mechanism=fcntl
PidFile: "/var/run/apache2/apache2.pid"
Define: DUMP_VHOSTS
Define: DUMP_RUN_CFG
Define: ENABLE_USR_LIB_CGI_BIN
User: name="www-data" id=33
Group: name="www-data" id=33
```


