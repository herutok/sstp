#!/bin/bash
#sstp (Wegare)
clear
host2="$(cat /root/akun/sstp.txt | tr '\n' ' '  | awk '{print $1}')" 
user2="$(cat /root/akun/sstp.txt | tr '\n' ' '  | awk '{print $2}')" 
pass2="$(cat /root/akun/sstp.txt | tr '\n' ' '  | awk '{print $3}')" 
echo "Inject sstp by wegare"
echo "1. Sett Profile"
echo "2. Start Inject"
echo "3. Stop Inject"
echo "4. Enable auto booting & auto rekonek"
echo "5. Disable auto booting & auto rekonek"
echo "e. exit"
read -p "(default tools: 2) : " tools
[ -z "${tools}" ] && tools="2"
if [ "$tools" = "1" ]; then

echo "Masukkan bug.com.host:port" 
read -p "default bug.com.host:port: $host2 : " host
[ -z "${host}" ] && host="$host2"

echo "Masukkan username" 
read -p "default username: $user2 : " user
[ -z "${user}" ] && user="$user2"

echo "Masukkan password" 
read -p "default password: $pass2 : " pass
[ -z "${pass}" ] && pass="$pass2"

#echo "Masukkan bug" 
#read -p "default bug: $bug2 : " bug
##[ -z "${bug}" ] && bug="$bug2"

echo "$host
$user
$pass" > /root/akun/sstp.txt
echo "Sett Profile Sukses"
sleep 2
clear
/usr/bin/sstp
elif [ "${tools}" = "2" ]; then
ipmodem="$(route -n | grep -i 0.0.0.0 | head -n1 | awk '{print $2}')" 
echo "ipmodem=$ipmodem" > /root/akun/ipmodem.txt
host="$(cat /root/akun/sstp.txt | tr '\n' ' '  | awk '{print $1}')" 
user="$(cat /root/akun/sstp.txt | tr '\n' ' '  | awk '{print $2}')" 
pass="$(cat /root/akun/sstp.txt | tr '\n' ' '  | awk '{print $3}')" 
route="$(cat /root/akun/ipmodem.txt | grep -i ipmodem | cut -d= -f2 | tail -n1)"
sleep 1
sstpc --cert-warn --password $pass --user $user --log-level 5 --log-stdout --save-server-route --tls-ext $host require-mschap-v2 refuse-chap refuse-pap noauth nodeflate &
sleep 8
pp="$(route -n | grep ppp | head -n1 | awk '{print $8}')" 
inet="$(ip r | grep $pp | head -n1 | awk '{print $9}')" 
route add default gw $inet metric 0
iptables -A POSTROUTING --proto tcp -t nat -o $pp -j MASQUERADE
sleep 2
fping -l google.com > /dev/null 2>&1 &
elif [ "${tools}" = "3" ]; then
host="$(cat /root/akun/sstp.txt | tr '\n' ' '  | awk '{print $1}')" 
route="$(cat /root/akun/ipmodem.txt | grep -i ipmodem | cut -d= -f2 | tail -n1)" 
bles="$(iptables -t nat -v -L POSTROUTING -n --line-number | grep ppp | head -n1 | awk '{print $1}')" 
killall -q sstpc fping
route del "$host" gw "$route" metric 0 2>/dev/null
iptables -t nat -D POSTROUTING $bles 2>/dev/null
killall dnsmasq 
/etc/init.d/dnsmasq start > /dev/null
sleep 2
echo "Stop Suksess"
sleep 2
clear
/usr/bin/sstp
elif [ "${tools}" = "4" ]; then
cat <<EOF>> /etc/crontabs/root

# BEGIN AUTOREKONEKSSTP
*/1 * * * *  autorekonek-sstp
# END AUTOREKONEKSSTP
EOF
sed -i '/^$/d' /etc/crontabs/root 2>/dev/null
/etc/init.d/cron restart
echo "Enable Suksess"
sleep 2
clear
/usr/bin/sstp
elif [ "${tools}" = "5" ]; then
sed -i "/^# BEGIN AUTOREKONEKSSTP/,/^# END AUTOREKONEKSSTP/d" /etc/crontabs/root > /dev/null
/etc/init.d/cron restart
echo "Disable Suksess"
sleep 2
clear
/usr/bin/sstp
elif [ "${tools}" = "e" ]; then
clear
exit
else 
echo -e "$tools: invalid selection."
exit
fi