
# cloud-config
package_upgrade: true
packages:
#- nfs-utils  (amazon linux only)
- nfs-common
- system-storage-manager
- apache2
- curl
- php
- libapache2-mod-php
- php-mcrypt
- php-mysql
- mysql-client
- rsync
runcmd:
- mkdir /website_data
- mkdir /backup_data
- echo "fs-29311c60.efs.us-east-1.amazonaws.com:/ /website_data nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0" >> /etc/fstab
#echo "fs-4d1bee34.efs.us-east-2.amazonaws.com:/ /backup_data nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0" >> /etc/fstab
- mount -a -t nfs4
# apache config
- cp /website_data/vhosts/* /etc/apache2/sites-available/
- sudo a2ensite *
- sudo a2enmod rewrite
- echo "ServerName localhost" | sudo tee /etc/apache2/conf-available/fqdn.conf
- sudo a2enconf fqdn
# modify php.ini file
- echo "upload_max_filesize = 1000M
post_max_size = 2000M
memory_limit = 3000M
file_uploads = On
max_execution_time = 300" >> /etc/php/7.0/apache2/php.ini

#hardening
- echo "tmpfs /run/shm tmpfs defaults,noexec,nosuid 0 0" >> /etc/fstab
- apt install unattended-upgrades -y
#Prevent IP spoofing
- perl -pi -e "s/order hosts,bind/​order bind,hosts/g" /etc/host.conf
- perl -pi -e "s/multi on/​​nospoof on/g" /etc/host.conf

#Harden the networking layer
- echo "# IP Spoofing protection
​net.ipv4.conf.all.rp_filter = 1
​net.ipv4.conf.default.rp_filter = 1
​
​# Ignore ICMP broadcast requests
​net.ipv4.icmp_echo_ignore_broadcasts = 1
​
​# Disable source packet routing
​net.ipv4.conf.all.accept_source_route = 0
​net.ipv6.conf.all.accept_source_route = 0
​net.ipv4.conf.default.accept_source_route = 0
​net.ipv6.conf.default.accept_source_route = 0
​
​# Ignore send redirects
​net.ipv4.conf.all.send_redirects = 0
​net.ipv4.conf.default.send_redirects = 0
​
​# Block SYN attacks
​net.ipv4.tcp_syncookies = 1
​net.ipv4.tcp_max_syn_backlog = 2048
​net.ipv4.tcp_synack_retries = 2
​net.ipv4.tcp_syn_retries = 5
​
​# Log Martians
​net.ipv4.conf.all.log_martians = 1
​net.ipv4.icmp_ignore_bogus_error_responses = 1
​
​# Ignore ICMP redirects
​net.ipv4.conf.all.accept_redirects = 0
​net.ipv6.conf.all.accept_redirects = 0
​net.ipv4.conf.default.accept_redirects = 0
​net.ipv6.conf.default.accept_redirects = 0
​
​# Ignore Directed pings
​net.ipv4.icmp_echo_ignore_all = 1" >> /etc/sysctl.conf
