# instal webserver
cd
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/dektian/script-jualan-ssh-vpn/master/conf/nginx.conf"
sed -i 's/www-data/nginx/g' /etc/nginx/nginx.conf
mkdir -p /home/vps/public_html
echo "<pre>Setup by Khairil G</pre>" > /home/vps/public_html/index.html
echo "<?php phpinfo(); ?>" > /home/vps/public_html/info.php
rm /etc/nginx/conf.d/*
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/dektian/script-jualan-ssh-vpn/master/conf/vps.conf"
sed -i 's/apache/nginx/g' /etc/php-fpm.d/www.conf
chmod -R +rx /home/vps
systemctl restart php-fpm 
systemctl restart nginx 

# install openvpn
wget -O /etc/openvpn/openvpn.zip "https://github.com/dektian/script-jualan-ssh-vpn/raw/master/conf/openvpn-key.zip"
cd /etc/openvpn/
unzip openvpn.zip
wget -O /etc/openvpn/1194.conf "https://raw.githubusercontent.com/dektian/script-jualan-ssh-vpn/master/conf/1194-centos.conf"
wget -O /etc/openvpn/1194.conf "https://raw.githubusercontent.com/dektian/script-jualan-ssh-vpn/master/conf/1194-centos64.conf"
wget -O /etc/iptables.up.rules "https://raw.githubusercontent.com/dektian/script-jualan-ssh-vpn/master/conf/iptables.up.rules"
sed -i '$ i\iptables-restore < /etc/iptables.up.rules' /etc/rc.local
sed -i '$ i\iptables-restore < /etc/iptables.up.rules' /etc/rc.d/rc.local
MYIP=`curl icanhazip.com`;
MYIP2="s/xxxxxxxxx/$MYIP/g";
sed -i $MYIP2 /etc/iptables.up.rules;
sed -i 's/venet0/eth0/g' /etc/iptables.up.rules
iptables-restore < /etc/iptables.up.rules
sysctl -w net.ipv4.ip_forward=1
sed -i 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/g' /etc/sysctl.conf
systemctl restart openvpn 
systemctl enable openvpn 
cd

# configure openvpn client config
cd /etc/openvpn/
wget -O /etc/openvpn/client.ovpn "https://raw.githubusercontent.com/dektian/script-jualan-ssh-vpn/master/openvpn.conf"
sed -i $MYIP2 /etc/openvpn/client.ovpn;
#PASS=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1`;
useradd -g 0 -d /root/ -s /bin/bash $dname
echo $dname:$dname"@2017" | chpasswd
echo $dname > pass.txt
echo $dname"@2017" >> pass.txt
tar cf client.tar client.ovpn pass.txt
cp client.tar /home/vps/public_html/
cp client.ovpn /home/vps/public_html/
