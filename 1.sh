  
#!/bin/bash
# Script Auto Installer by Indoworx
# www.indoworx.com
# initialisasi var
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

