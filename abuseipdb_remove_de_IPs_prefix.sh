#!/usr/bin/env bash

######## Duration bash Script check
SECONDS=0

######## Path finden
MY_PATH=$(cd "$MY_PATH" && pwd )

######## Address
addfeed='/var/www/feeds'
addfeedlog="$MY_PATH/log-10000-pro-day"
addarchv="$MY_PATH/log-blacklist_abuseipdb.com"

mkdir "$MY_PATH/log-10000-pro-day"
mkdir "$MY_PATH/log-blacklist_abuseipdb.com"

######## sort ip address
SORTIP() {
  sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4
}

WHITELIST='^192\.168|^172\.1[6789]\.|^172\.2[0-9]\.|^172\.3[01]\.'

####### DATE and UHR
DATE0=$(date -d "0 day ago" +%F)
DATE00=$(date -d "0 day ago" +"%d-%m-20%y um %H:%M Uhr")
DAY=$(date | awk '{print $1}')

######## remove germany ip prefix
cat "$MY_PATH/blacklist_abuseipdb.com.txt" | grep -v $WHITELIST | grep -v : | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"  > "$MY_PATH/log1-blacklist_abuseipdb.com_without_de_IPs.txt"


x=$(cat "$MY_PATH/log1-blacklist_abuseipdb.com_without_de_IPs.txt")

#https://www.maketecheasier.com/ip-address-geolocation-lookups-linux/
for ip in $x ; do
        geo1=$(geoiplookup "$(echo $ip | cut -d: -f2)")
        echo $ip $geo1 | sed 's/GeoIP Country Edition: /    #---> /g'  >> "$MY_PATH/log2-blacklist_abuseipdb.com_without_de_IPs.txt"
done

cat "$MY_PATH/log2-blacklist_abuseipdb.com_without_de_IPs.txt"                                                          > "$addarchv/archive.blacklist_abuseipdb.com-$DATE0-$DAY"
cat "$MY_PATH/log2-blacklist_abuseipdb.com_without_de_IPs.txt" | awk '{print $1,"  "$2,$4,$5,$6,$7}' | grep -v Germany  > "$MY_PATH/log3-blacklist_abuseipdb.com_without_de_IPs.txt"
cat "$MY_PATH/log3-blacklist_abuseipdb.com_without_de_IPs.txt" | awk '{print $1}'                                       > "$MY_PATH/log4-blacklist_abuseipdb.com_without_de_IPs.txt"
cat "$MY_PATH/log4-blacklist_abuseipdb.com_without_de_IPs.txt"                                                          > "$MY_PATH/blacklist_abuseipdb.com_without_de_IPs.txt"


COUNTIP=$(cat "$MY_PATH/blacklist_abuseipdb.com_without_de_IPs.txt" | wc | awk '{print $1}' | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' )

sed -i -e "1d" "$MY_PATH/blacklist_abuseipdb.com_without_de_IPs.txt"
sed -i "1i #Last Update von www.abuseipdb.com ist am $DATE00  -  $COUNTIP IPs"     "$MY_PATH/blacklist_abuseipdb.com_without_de_IPs.txt"
#sed -i "2i #remove all Germany IP prefix. "                                       "$MY_PATH/blacklist_abuseipdb.com_without_de_IPs.txt"

##### delete log1 and 2
rm "$MY_PATH/log1-blacklist_abuseipdb.com_without_de_IPs.txt"
rm "$MY_PATH/log2-blacklist_abuseipdb.com_without_de_IPs.txt"
rm "$MY_PATH/log3-blacklist_abuseipdb.com_without_de_IPs.txt"
rm "$MY_PATH/log4-blacklist_abuseipdb.com_without_de_IPs.txt"

######## Duration bash script check
echo "_________________________________"
ELAPSED="Duration Script: $(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec"
echo $ELAPSED
echo
