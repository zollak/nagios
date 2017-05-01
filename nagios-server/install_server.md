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
### Disable IPv6

```
sudo echo net.ipv6.conf.all.disable_ipv6=1 > /etc/sysctl.d/disableipv6.conf
sudo reboot
```

## DNS
```bash
cat /etc/hosts
```
```
127.0.0.1        localhost
107.170.80.72    nagios.example.com
```
Set A record on your DNS provider!

## Hostname, FQDN
```bash
cat /etc/hostname
```
```
nagios.example.com
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

## Environment settings: [.bashrc](../../.bashrc)

```bash
vi ~/.bashrc
```

## Set configuration management

```
sudo dpkg-reconfigure debconf
```
Dialog/low

## Time zone and date

```bash
date
sudo apt-get install ntpdate
sudo mv /etc/localtime /etc/localtime-old
sudo ln -sf /usr/share/zoneinfo/Europe/Budapest /etc/localtime
sudo echo 'Europe/Budapest' > /etc/timezone
date
```

Set /etc/cron.daily/[ntpdate](etc/cron.daily/ntpdate)
```bash
vi /etc/cron.daily/ntpdate
chmod +x /etc/cron.daily/ntpdate
/etc/cron.daily/ntpdate
```

Check Offset (after nagios-nrpe-plugin package installed):
```bash
/usr/lib/nagios/plugins/check_ntp_time -H europe.pool.ntp.org -w 30 -c 60
```

## Set Sendmail as MTA

```bash
sudo apt-get install sendmail
```
Modify /etc/mail/[sendmail.mc](etc/mail/sendmail.mc)
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

Look at the MASQUERADE_AS... line...

/etc/init.d/sendmail restart

## Automatic update

Install service
```bash
sudo apt-get install unattended-upgrades
```
Set unattended upgrades in /etc/apt/apt.conf.d/[50unattended-upgrades](etc/apt/apt.conf.d/50unattended-upgrades)

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
sudo vi /etc/apt/apt.conf.d/20auto-upgrades
```

## NAGIOS

```bash
sudo apt-get install nagios3 nagios-nrpe-plugin
```
Default web interface username: nagiosadmin

A bit later we'll change it. No need to remember it.

Create objects dir to store host's config file:
```bash
sudo mkdir /etc/nagios3/objects
```
Create own host as /etc/nagios3/objects/[nagios.example.com.cfg](etc/nagios3/objects/nagios.example.com.cfg)
```bash
sudo vi /etc/nagios3/objects/nagios.example.com.cfg
```
Modify Nagios server main config file /etc/nagios3/[nagios.cfg](etc/nagios3/nagios.cfg)
```bash
sudo vi /etc/nagios3/nagios.cfg
```
Create Apache VHOST file: /etc/apache2/sites-available/[ssl.conf](etc/apache2/sites-available/ssl.conf)
```bash
sudo vi /etc/apache2/sites-available/ssl.conf
```
Set required module and VHOST's:
```bash
sudo a2enmod ssl
sudo a2ensite ssl
sudo a2dissite 000-default
```

SSL cert rights in /etc/ssl
```
-rw-r----- 1 root www-data 2.2K Feb 19 20:45 sn.crt
-rw-r----- 1 root www-data 3.2K Feb 19 20:32 sn.key
-rw-r----- 1 root www-data 4.8K Feb 19 21:02 startssl.CA.chain.class2.crt
```

We don't need to listen on port 443, that's why modify /etc/apache2/[ports.conf](etc/apache2/ports.conf)
```bash
sudo vi /etc/apache2/ports.conf
```
Create own user to nagios web interface:
```bash
sudo htpasswd -cs /etc/nagios3/htpasswd.users zollak
New password: KeePass
```

Delete default user from web interface:
```bash
sudo htpasswd -D /etc/nagios3/htpasswd.users nagiosadmin
```
You also need to change the username in the /etc/nagios3/[cgi.cfg](etc/nagios3/cgi.cfg) file.
```bash
sudo vi /etc/nagios3/cgi.cfg
```
Allow Externel commands in Web interface:
```bash
sudo /etc/init.d/nagios3 stop
sudo dpkg-statoverride --update --add nagios www-data 2710 /var/lib/nagios3/rw
sudo dpkg-statoverride --update --add nagios nagios 751 /var/lib/nagios3
```
Modify /etc/nagios-plugins/config/[check_nrpe.cfg](etc/nagios-plugins/config/check_nrpe.cfg) for common ports
```bash
sudo vi /etc/nagios-plugins/config/check_nrpe.cfg
```

Modify /etc/nagios3/[commands.cfg](etc/nagios3/commands.cfg) - Mibipush notifications
```bash
sudo vi /etc/nagios3/commands.cfg
```
Set notifications. Modify /etc/nagios3/conf.d/[contacts_nagios2.cfg](etc/nagios3/conf.d/contacts_nagios2.cfg)
```bash
sudo vi /etc/nagios3/conf.d/contacts_nagios2.cfg
sudo vi /etc/nagios3/conf.d/hostgroups_nagios2.cfg
sudo vi  /etc/nagios3/conf.d/localhost_nagios2.cfg
sudo vi  /etc/nagios3/conf.d/generic-service_nagios2.cfg
sudo vi /etc/nagios3/conf.d/services_nagios2.cfg
```

### Checks
```bash
sudo dpkg --get-selections | grep nagios
```
```
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
```
```bash
nagios3 -v /etc/nagios3/nagios.cfg
```

### Restart service
```bash
/etc/init.d/nagios3 restart
/etc/init.d/apache2 restart
```
Login to browser:

URL: http://107.170.80.72:40000/nagios3/

Username: zollak

Password: KeePass

### Set passive check

sudo dpkg -i nagios-passive-safenet_3.8_amd64.deb
sudo vi /etc/cron.d/passive-check-ssh-port

check_name="check_ssh";param=" -p 15951 -H localhost"

sudo n2enablecheck --list
sudo n2enablecheck rkhunter

## Security

Delete not necessarry packages:
```bash
sudo apt-get purge byobu wpasupplicant
```

### Rkhunter

Install:
```bash
wget http://downloads.sourceforge.net/project/rkhunter/rkhunter/1.4.2/rkhunter-1.4.2.tar.gz
tar xzvf rkhunter-1.4.2.tar.gz -C /tmp/
cd /tmp/rkhunter-1.4.2/
./installer.sh --layout /usr --install
apt-get install binutils libreadline5 libruby1.8 ruby ruby1.8 ssl-cert unhide.rb
rkhunter --versioncheck
rkhunter --update
rkhunter --propupd
blkid
```

Create /etc/[rkhunter.conf.local](etc/rkhunter.conf.local)

```bash
sudo vi /etc/rkhunter.conf.local
chmod 640 /etc/rkhunter.conf.local
rkhunter --propupd
```
Set notifications /etc/[aliases](etc/aliases)
```bash
vi /etc/aliases
newaliases
```

Update database if we know what was the reason of the modification:
```
sudo rkhunter --propupd
```
Basic check:
```bash
sudo rkhunter --propupd && check_name="check_rkhunter";param="";send_name="Rkhunter_daily";if [ -f /usr/lib/nagios/plugins/$check_name ];then nagios_server_ip=$(awk -F "=" '$1=="nagios_server_ip"{print $2}' /etc/nsca/passive-checks.cfg);check=$(/usr/lib/nagios/plugins/$check_name $param);code=$?;echo "$(hostname --fqdn);$send_name;$code;$check"|/usr/local/sbin/send_nsca_amd64 -d ";" -H $nagios_server_ip -c /etc/nsca/send_nsca.cfg; fi
grep "Warning:" -A1 /var/log/rkhunter.log
```

### Fail2ban

```bash
apt-get install fail2ban
```
Howto:

> https://www.digitalocean.com/community/articles/how-to-protect-ssh-with-fail2ban-on-ubuntu-12-04

> http://hup.hu/node/130645 

> http://www.fail2ban.org/wiki/index.php/Fail2ban:Community_Portal


Create /etc/fail2ban/action.d/[iptables-multiport-permanent.conf](etc/fail2ban/action.d/iptables-multiport-permanent.conf) file.
```bash
vi /etc/fail2ban/action.d/iptables-multiport-permanent.conf
```
This script save banned IP-'s to /etc/fail2ban/permanent_xxxxx_ban.conf files. After restart fail2ban service this script will read banned IP's from these files.

Create /etc/fail2ban/[jail.local](etc/fail2ban/jail.local) file.
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

### Logwatch

> https://www.digitalocean.com/community/tutorials/how-to-install-and-use-logwatch-log-analyzer-and-reporter-on-a-vps

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
TODO
```bash
vi /etc/cron.daily/00logwatch
```

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


