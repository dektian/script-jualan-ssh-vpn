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
wget http://prdownloads.sourceforge.net/webadmin/webmin-1.831-1.noarch.rpm
yum -y install perl perl-Net-SSLeay openssl perl-IO-Tty
rpm -U webmin*
rm -f webmin*
sed -i -e 's/ssl=1/ssl=0/g' /etc/webmin/miniserv.conf
systemctl restart webmin
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
systemctl start nginx
systemctl restart php-fpm
systemctl restart vnstat
systemctl restart openvpn
systemctl restart snmpd
systemctl restart sshd
systemctl restart dropbear
systemctl restart fail2ban
systemctl restart squid
systemctl restart webmin
systemctl start crond
systemctl enable crond
