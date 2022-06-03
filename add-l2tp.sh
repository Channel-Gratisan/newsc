#!/bin/bash
source /var/lib/premium-script/ipvps.conf
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
MYIP=$(wget -qO- ipinfo.io/ip);
IZIN=$( curl https://raw.githubusercontent.com/Channel-Gratisan/newsc/main/ip.sh | grep $MYIP )
if [ $MYIP = $IZIN ]; then
clear
echo -e "${green} Please Wait, Proses...${NC}"
sleep 5
else
echo "User premium Only ,Sila Contact Admin Bot😘"
exit 0
fi
until [[ $VPN_USER =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
		read -rp "Username: " -e VPN_USER
		CLIENT_EXISTS=$(grep -w $VPN_USER /var/lib/premium-script/data-user-l2tp | wc -l)

		if [[ ${CLIENT_EXISTS} == '1' ]]; then
			echo ""
			echo "A client with the specified name was already created, please choose another name."
			exit 1
		fi
	done
read -p "Password: " VPN_PASSWORD
read -p "Expired (days): " masaaktif
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
clear

# Add or update VPN user
cat >> /etc/ppp/chap-secrets <<EOF
"$VPN_USER" l2tpd "$VPN_PASSWORD" *
EOF

VPN_PASSWORD_ENC=$(openssl passwd -1 "$VPN_PASSWORD")
cat >> /etc/ipsec.d/passwd <<EOF
$VPN_USER:$VPN_PASSWORD_ENC:xauth-psk
EOF

# Update file attributes
chmod 600 /etc/ppp/chap-secrets* /etc/ipsec.d/passwd*
echo -e "### $VPN_USER $exp">>"/var/lib/premium-script/data-user-l2tp"
cat <<EOF

================================
L2TP/IPSEC PSK VPN

Server IP    : $PUBLIC_IP
IPsec PSK    : myvpn
Username     : $VPN_USER
Password     : $VPN_PASSWORD
Expired ON   : $exp
=================================
     Script BY MASWAY
=================================
EOF
