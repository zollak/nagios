# Install Nagios server to own VPS (Ubuntu)

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
```
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


