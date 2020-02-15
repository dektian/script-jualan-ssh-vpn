#!/bin/bash
# instalasi server VPN dan Cloud-torrent
OS=`uname -p`;

# data pemilik server
read -p "Nama pemilik server: " namap
read -p "Nomor HP atau Email pemilik server: " nhp
read -p "Masukkan username untuk akun default: " dname

# ubah hostname
echo "Hostname Anda saat ini $HOSTNAME"
read -p "Masukkan hostname atau nama untuk server ini: " hnbaru
echo "HOSTNAME=$hnbaru" >> /etc/sysconfig/network
hostname "$hnbaru"
echo "Hostname telah diganti menjadi $hnbaru"
read -p "Maks login user (contoh 1 atau 2): " llimit
echo "Proses instalasi script dimulai....."

# Banner SSH
echo "## SELAMAT DATANG DI SERVER PREMIUM $hnbaru ## " >> /etc/pesan
echo "DENGAN MENGGUNAKAN LAYANAN SSH DARI SERVER INI BERARTI ANDA SETUJU SEGALA KETENTUAN YANG TELAH KAMI BUAT: " >> /etc/pesan
echo "1. Tidak diperbolehkan untuk melakukan aktivitas illegal seperti DDoS, Hacking, Phising, Spam, dan Torrent di server ini; " >> /etc/pesan
echo "2. Maks login $llimit kali, jika lebih dari itu maka akun otomatis ditendang oleh server; " >> /etc/pesan
echo "3. Pengguna setuju jika kami mengetahui atau sistem mendeteksi pelanggaran di akunnya maka akun akan dihapus oleh sistem; " >> /etc/pesan
echo "4. Tidak ada tolerasi bagi pengguna yang melakukan pelanggaran; " >> /etc/pesan
echo "Server by $namap ( $nhp )" >> /etc/pesan

echo "Banner /etc/pesan" >> /etc/ssh/sshd_config

# update software server
yum update -y

# go to root
cd

# disable se linux
echo 0 > /selinux/enforce
sed -i 's/SELINUX=enforcing/SELINUX=disable/g'  /etc/sysconfig/selinux

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
service sshd restart

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.d/rc.local

# install wget and curl
yum -y install wget curl

# setting Repo EPEL dan REMI
sudo yum -y install epel-release
#CentOS/RHEL 7 REMI
sudo yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm   

# instal rpmforge x64
#wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el7.rf.x86_64.rpm
wget https://raw.githubusercontent.com/dektian/script-jualan-ssh-vpn/master/app/rpmforge.rpm
rpm -Uvh rpmforge.rpm

# enabled RPMforge dan REMI repo
sed -i 's/enabled = 1/enabled = 0/g' /etc/yum.repos.d/rpmforge.repo
sed -i -e "/^\[remi\]/,/^\[.*\]/ s|^\(enabled[ \t]*=[ \t]*0\\)|enabled=1|" /etc/yum.repos.d/remi.repo

# hapus downloadan rpm
rm -f *.rpm

# update library
yum -y update

# ada keamanan server
# gak usah aja 

# install webserver *update di centos 7
yum -y install nginx php-fpm php-cli
systemctl restart nginx 
systemctl restart php-fpm 
systemctl enable nginx
systemctl enable php-fpm 
#kode lama centos 6
#service nginx restart
#service php-fpm restart
#chkconfig nginx on
#chkconfig php-fpm on

# matikan exim tapi ga ada 

# install screenfetch
cd
wget https://raw.githubusercontent.com/dektian/script-jualan-ssh-vpn/master/app/screenfetch-dev
mv screenfetch-dev /usr/bin/screenfetch
chmod +x /usr/bin/screenfetch
echo "clear" >> .bash_profile
echo "screenfetch" >> .bash_profile

# install essential package
yum -y install rrdtool screen iftop htop nmap bc nethogs openvpn vnstat ngrep mtr git zsh mrtg unrar rsyslog rkhunter mrtg net-snmp net-snmp-utils expect nano bind-utils
yum -y groupinstall 'Development Tools'
yum -y install cmake
yum -y --enablerepo=rpmforge install axel sslh ptunnel unrar

# setting vnstat
vnstat -u -i eth0
echo "MAILTO=root" > /etc/cron.d/vnstat
echo "*/5 * * * * root /usr/sbin/vnstat.cron" >> /etc/cron.d/vnstat
systemctl restart vnstat
systemctl enable vnstat 
#service vnstat restart
#chkconfig vnstat on

# install screenfetch
cd
wget https://raw.githubusercontent.com/dektian/script-jualan-ssh-vpn/master/app/screenfetch-dev
mv screenfetch-dev /usr/bin/screenfetch
chmod +x /usr/bin/screenfetch
echo "clear" >> .bash_profile
echo "screenfetch" >> .bash_profile

# instal webserver
cd
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/dektian/script-jualan-ssh-vpn/master/conf/nginx.conf"
sed -i 's/www-data/nginx/g' /etc/nginx/nginx.conf
mkdir -p /home/vps/public_html
echo "<pre>Setup by dektian </pre>" > /home/vps/public_html/index.html
echo "<?php phpinfo(); ?>" > /home/vps/public_html/info.php
rm /etc/nginx/conf.d/*
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/dektian/script-jualan-ssh-vpn/master/conf/vps.conf"
sed -i 's/apache/nginx/g' /etc/php-fpm.d/www.conf
chmod -R +rx /home/vps
systemctl restart php-fpm 
systemctl restart nginx 

# tanpa openvpn, independen install

# install badvpn
cd
wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/dektian/script-jualan-ssh-vpn/master/conf/badvpn-udpgw"
#if [ "$OS" == "x86_64" ]; then
wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/dektian/script-jualan-ssh-vpn/master/conf/badvpn-udpgw64"
#fi
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.local
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.d/rc.local
chmod +x /usr/bin/badvpn-udpgw
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300

# install mrtg
cd /etc/snmp/
wget -O /etc/snmp/snmpd.conf "https://raw.githubusercontent.com/dektian/script-jualan-ssh-vpn/master/conf/snmpd.conf"
wget -O /root/mrtg-mem.sh "https://raw.githubusercontent.com/dektian/script-jualan-ssh-vpn/master/conf/mrtg-mem.sh"
chmod +x /root/mrtg-mem.sh
systemctl restart snmpd 
systemctl enable snmpd
#service snmpd restart
#chkconfig snmpd on
snmpwalk -v 1 -c public localhost | tail
mkdir -p /home/vps/public_html/mrtg
cfgmaker --zero-speed 100000000 --global 'WorkDir: /home/vps/public_html/mrtg' --output /etc/mrtg/mrtg.cfg public@localhost
curl "https://raw.githubusercontent.com/dektian/script-jualan-ssh-vpn/master/conf/mrtg.conf" >> /etc/mrtg/mrtg.cfg
sed -i 's/WorkDir: \/var\/www\/mrtg/# WorkDir: \/var\/www\/mrtg/g' /etc/mrtg/mrtg.cfg
sed -i 's/# Options\[_\]: growright, bits/Options\[_\]: growright/g' /etc/mrtg/mrtg.cfg
indexmaker --output=/home/vps/public_html/mrtg/index.html /etc/mrtg/mrtg.cfg
echo "0-59/5 * * * * root env LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg" > /etc/cron.d/mrtg
LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg
LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg
LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg

# setting port ssh
cd
sed -i '/Port 22/a Port 143' /etc/ssh/sshd_config
sed -i 's/#Port 22/Port  22/g' /etc/ssh/sshd_config
systemctl restart sshd
systemctl enable sshd
#service sshd restart
#chkconfig sshd on

# install dropbear
yum -y install dropbear
echo "OPTIONS=\"-p 80 -p 109 -p 110 -p 443 -b /etc/pesan\"" > /etc/sysconfig/dropbear
echo "/bin/false" >> /etc/shells
echo "PIDFILE=/var/run/dropbear.pid" >> /etc/init.d/dropbear
systemctl restart dropbear
systemctl enable dropbear
#service dropbear restart
#chkconfig dropbear on

# install vnstat gui
cd /home/vps/public_html/
wget https://raw.githubusercontent.com/dektian/script-jualan-ssh-vpn/master/app/vnstat_php_frontend-1.5.1.tar.gz
tar xf vnstat_php_frontend-1.5.1.tar.gz
rm vnstat_php_frontend-1.5.1.tar.gz
mv vnstat_php_frontend-1.5.1 vnstat
cd vnstat
sed -i "s/\$iface_list = array('eth0', 'sixxs');/\$iface_list = array('eth0');/g" config.php
sed -i "s/\$language = 'nl';/\$language = 'en';/g" config.php
sed -i 's/Internal/Internet/g' config.php
sed -i '/SixXS IPv6/d' config.php

# install fail2ban
cd
yum -y install fail2ban
systemctl restart fail2ban
systemctl enable fail2ban
#service fail2ban restart
#chkconfig fail2ban on

# install squid
yum -y install squid
wget -O /etc/squid/squid.conf "https://raw.githubusercontent.com/dektian/script-jualan-ssh-vpn/master/conf/squid-centos.conf"
sed -i $MYIP2 /etc/squid/squid.conf;
systemctl restart squid
systemctl enable squid
#service squid restart
#chkconfig squid on

# install webmin
cd
wget http://prdownloads.sourceforge.net/webadmin/webmin-1.890-1.noarch.rpm
yum -y install perl perl-Net-SSLeay openssl perl-IO-Tty perl-Encode-Detect perl-Digest-MD5
rpm -U webmin*
rm -f webmin*
sed -i -e 's/ssl=1/ssl=0/g' /etc/webmin/miniserv.conf
service webmin restart 
systemctl enable webmin
#service webmin restart
#chkconfig webmin on

# pasang bmon
#if [ "$OS" == "x86_64" ]; then
wget -O /usr/bin/bmon "https://raw.githubusercontent.com/dektian/script-jualan-ssh-vpn/master/conf/bmon64"
#else
#  wget -O /usr/bin/bmon "https://raw.githubusercontent.com/dektian/script-jualan-ssh-vpn/master/conf/bmon"
#fi
chmod +x /usr/bin/bmon

# auto kill multi login
#echo "while :" >> /usr/bin/autokill
#echo "  do" >> /usr/bin/autokill
#echo "  userlimit $llimit" >> /usr/bin/autokill
#echo "  sleep 20" >> /usr/bin/autokill
#echo "  done" >> /usr/bin/autokill

# downlaod script
cd /usr/bin
wget -O speedtest "https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py"
wget -O bench "https://raw.githubusercontent.com/dektian/script-jualan-ssh-vpn/master/bench-network.sh"
wget -O mem "https://raw.githubusercontent.com/pixelb/ps_mem/master/ps_mem.py"
wget -O userlogin "https://raw.githubusercontent.com/dektian/script-jualan-ssh-vpn/master/user-login.sh"
wget -O userexpire "https://raw.githubusercontent.com/dektian/script-jualan-ssh-vpn/master/autoexpire.sh"
wget -O usernew "https://raw.githubusercontent.com/dektian/script-jualan-ssh-vpn/master/create-user.sh"
wget -O userdelete "https://raw.githubusercontent.com/dektian/script-jualan-ssh-vpn/master/user-delete.sh"
wget -O userlimit "https://github.com/dektian/script-jualan-ssh-vpn/raw/master/user-limit.sh"
wget -O renew "https://raw.githubusercontent.com/dektian/script-jualan-ssh-vpn/master/user-renew.sh"
wget -O userlist "https://raw.githubusercontent.com/dektian/script-jualan-ssh-vpn/master/user-list.sh" 
wget -O trial "https://raw.githubusercontent.com/dektian/script-jualan-ssh-vpn/master/user-trial.sh"
echo "cat /root/log-install.txt" | tee info
echo "speedtest --share" | tee speedtest
wget -O /root/chkrootkit.tar.gz ftp://ftp.pangeia.com.br/pub/seg/pac/chkrootkit.tar.gz
tar zxf /root/chkrootkit.tar.gz -C /root/
rm -f /root/chkrootkit.tar.gz
mv /root/chk* /root/chkrootkit
wget -O checkvirus "https://github.com/dektian/script-jualan-ssh-vpn/raw/master/checkvirus.sh"
#wget -O cron-autokill "https://raw.githubusercontent.com/dektian/script-jualan-ssh-vpn/master/cron-autokill.sh"
wget -O cron-dropcheck "https://github.com/dektian/script-jualan-ssh-vpn/raw/master/cron-dropcheck.sh"

# sett permission
chmod +x userlogin
chmod +x userdelete
chmod +x userexpire
chmod +x usernew
chmod +x userlist
chmod +x userlimit
chmod +x renew
chmod +x trial
chmod +x info
chmod +x speedtest
chmod +x bench
chmod +x mem
chmod +x checkvirus
#chmod +x autokill
#chmod +x cron-autokill
chmod +x cron-dropcheck

# cron
cd
systemctl enable crond
systemctl stop crond 
#chkconfig crond on
#service crond stop
echo "0 */12 * * * root /bin/sh /usr/bin/userexpire" > /etc/cron.d/user-expire
echo "0 */12 * * * root /bin/sh /usr/bin/reboot" > /etc/cron.d/reboot
#echo "* * * * * root /bin/sh /usr/bin/cron-autokill" > /etc/cron.d/autokill
echo "* * * * * root /bin/sh /usr/bin/cron-dropcheck" > /etc/cron.d/dropcheck
#echo "0 */1 * * * root killall /bin/sh" > /etc/cron.d/killak

# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# finalisasi
chown -R nginx:nginx /home/vps/public_html
systemctl restart nginx
systemctl restart php-fpm
systemctl restart vnstat
systemctl restart openvpn
systemctl restart snmpd
systemctl restart sshd
systemctl restart dropbear
systemctl restart fail2ban
systemctl restart squid
service webmin restart 
systemctl start crond
systemctl enable crond

# template openvpn
cd /usr/bin
sudo wget -O ovpn "https://raw.githubusercontent.com/dektian/script-jualan-ssh-vpn/master/openvpn-install.sh" && chmod +x ovpn && sh ovpn 
cd 

# instal docker
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo "https://download.docker.com/linux/centos/docker-ce.repo"
sudo yum install docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
systemctl enable docker
#sudo docker run hello-world

# install cloud-torrent
curl https://i.jpillora.com/cloud-torrent! | bash
docker run --name ct -d -p 63000:63000 --restart always -v /root/downloads:/downloads jpillora/cloud-torrent --port 63000

# info
echo "Layanan yang diaktifkan"  | tee -a log-install.txt
echo "--------------------------------------"  | tee -a log-install.txt
#echo "OpenVPN : TCP 1194 (client config : http://$MYIP:81/client.ovpn)"  | tee -a log-install.txt
echo "Port OpenSSH : 22, 143"  | tee -a log-install.txt
echo "Port Dropbear : 80, 109, 110, 443"  | tee -a log-install.txt
echo "SquidProxy    : 8080, 8888, 3128 (limit to IP SSH)"  | tee -a log-install.txt
echo "Nginx : 81"  | tee -a log-install.txt
echo "badvpn   : badvpn-udpgw port 7300"  | tee -a log-install.txt
echo "Webmin   : http://$MYIP:10000/"  | tee -a log-install.txt
echo "vnstat   : http://$MYIP:81/vnstat/"  | tee -a log-install.txt
echo "MRTG     : http://$MYIP:81/mrtg/"  | tee -a log-install.txt
echo "Timezone : Asia/Jakarta"  | tee -a log-install.txt
echo "Fail2Ban : [on]"  | tee -a log-install.txt
echo "IPv6     : [off]"  | tee -a log-install.txt
echo "Root Login on Port 22 : [disabled]"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Tools"  | tee -a log-install.txt
echo "-----"  | tee -a log-install.txt
echo "axel, bmon, htop, iftop, mtr, nethogs"  | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "Account Default (untuk SSH dan VPN)"  | tee -a log-install.txt
echo "---------------"  | tee -a log-install.txt
echo "User     : $dname"  | tee -a log-install.txt
echo "Password : $dname@2017"  | tee -a log-install.txt
echo "sudo su telah diaktifkan pada user $dname"  | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "Script Command"  | tee -a log-install.txt
echo "--------------"  | tee -a log-install.txt
echo "speedtest --share : untuk cek speed vps"  | tee -a log-install.txt
echo "mem : untuk melihat pemakaian ram"  | tee -a log-install.txt
echo "checkvirus : untuk scan virus / malware"  | tee -a log-install.txt
echo "bench : untuk melihat performa vps" | tee -a log-install.txt
echo "usernew : untuk membuat akun baru"  | tee -a log-install.txt
echo "userlist : untuk melihat daftar akun beserta masa aktifnya"  | tee -a log-install.txt
echo "userlimit <limit> : untuk kill akun yang login lebih dari <limit>. Cth: userlimit 1"  | tee -a log-install.txt
echo "userlogin  : untuk melihat user yang sedang login"  | tee -a log-install.txt
echo "userdelete  : untuk menghapus user"  | tee -a log-install.txt
echo "trial : untuk membuat akun trial selama 1 hari"  | tee -a log-install.txt
echo "renew : untuk memperpanjang masa aktif akun"  | tee -a log-install.txt
echo "info : untuk melihat ulang informasi ini"  | tee -a log-install.txt
echo "--------------"  | tee -a log-install.txt
echo "CATATAN: Karena alasan keamanan untuk login ke user root silahkan gunakan port 443" | tee -a log-install.txt
rm -f /root/set-ssh.sh






