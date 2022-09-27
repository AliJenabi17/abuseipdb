#!/usr/bin/env bash

#https://github.com/cyqsimon/IP-Block-Script

######## Path finden
MY_PATH=$(cd "$MY_PATH" && pwd )

######## Address
addfeed='/var/www/feeds'
addfeedlog="$MY_PATH/log-10000-pro-day"

mkdir "$MY_PATH/log-10000-pro-day"

######## sort ip address
SORTIP() {
  sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4
}

WHITELIST='^192\.168|^172\.1[6789]\.|^172\.2[0-9]\.|^172\.3[01]\.'

####### DATE and UHR
DATE0=$(date -d "0 day ago" +%F)
DATE00=$(date -d "0 day ago" +"%d-%m-20%y um %H:%M Uhr")

####### get abuse ip
LIST_FILE="blacklist_abuseipdb_$DATE0"
API_KEY='insert your key'

curl -G https://api.abuseipdb.com/api/v2/blacklist \
  -H "Key: $API_KEY" \
  -H "Accept: text/plain" \
  > $LIST_FILE

######## move logs
mv $LIST_FILE $addfeedlog

######## find ip in 60 day and copy to feed.
cat  $(ls $addfeedlog/* | grep 'blacklist'   | sort -r | head -n 60 )                                                               > "$MY_PATH/blacklist_abuseipdb.com-1.txt"
cat "$MY_PATH/blacklist_abuseipdb.com-1.txt" | sort -u | egrep -v $WHITELIST | SORTIP | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"  > "$MY_PATH/blacklist_abuseipdb.com.txt"
rm  "$MY_PATH/blacklist_abuseipdb.com-1.txt"

COUNTIP=$(cat "$MY_PATH/blacklist_abuseipdb.com.txt" | wc | awk '{print $1}' | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' )
sed -i "1s/^/#Last Update von www.abuseipdb.com ist am $DATE00  -  $COUNTIP IPs \n/" "$MY_PATH/blacklist_abuseipdb.com.txt"

#sudo cp "$MY_PATH/blacklist_abuseipdb.com.txt"    "$addfeed/blacklist_abuseipdb.com.txt"

######## find and remove file more than 100 day oder more than 100 file.
find $addfeedlog/* -type f | sort -n | head -n -100 | xargs -d '\n' rm -f
