#!/bin/bash

#!/bin/sh
echo "Collecting data..."
echo ""
cat /proc/net/arp | grep : | grep ^192 | grep -v 00:00:00:00:00:00 | awk '{print $1}' > mac-ip
iptables -N UPLOAD
iptables -N DOWNLOAD
while read line;do iptables -I FORWARD 1 -s $line -j UPLOAD;done < mac-ip
while read line;do iptables -I FORWARD 1 -d $line -j DOWNLOAD;done < mac-ip

sleep 1
echo "Active Downloading Terminals:"
echo ""
iptables -nvx -L FORWARD | grep DOWNLOAD | awk 'BEGIN{OFS="\t"}NR==FNR{a[$3]=$4}NR>FNR{if($2>0)print $2/1024/1" KB/s ",$1/10" packets/s", a[$9], $9}' /tmp/dhcp.leases - | sort -n -r
echo ""
echo "Active Uploading Terminals:"
echo ""
iptables -nvx -L FORWARD | grep UPLOAD | awk 'BEGIN{OFS="\t"}NR==FNR{a[$3]=$4}NR>FNR{if($2>0)print $2/1024/1" KB/s ",$1/10" packets/s", a[$8], $8}' /tmp/dhcp.leases - | sort -n -r

while read line;do iptables -D FORWARD -s $line -j UPLOAD;done < mac-ip
while read line;do iptables -D FORWARD -d $line -j DOWNLOAD;done < mac-ip
