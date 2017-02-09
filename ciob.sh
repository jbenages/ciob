#!/bin/bash
# Ciob by Jesús Benages
# Simple check ip on blacklist script
# 
# TO START
# 1-Add ips that you want check on ip.txt file with return separation, you can put comment with #.
# 2-Make blacklist providers on blacklistProvider.txt file with carriage return separation between each domain or can use the example list, you can put comment with #.
# 3-Set email in email variable to send results of check.
# 4-Configure daily cron to check IPs.

#Usage
#mv exampleBlackListProvider.txt blacklistProvider.txt
#mv exampleIp.txt ip.txt
#bash ciob.sh


declare fileIp="ip.txt"
declare fileBlackListChecker="blacklistChecker.txt"
declare email="blacklist@example.com"
declare finalMessage=""
declare ipMessage=""

checkBlackList() {

	declare finalResult=""
	declare resultDNSQuery=""
	declare ip="$1" 	
	declare reverseIP=$( echo "$ip" | awk -F. '{print $4"."$3"." $2"."$1}' )

	while IFS= read -r domainBlackListChecker
	do

		if [[ $domainBlackListChecker != \#* ]]; then		
	        	resultDNSQuery=$( dig A +time=10 +tries=1 +short  "$reverseIP.$domainBlackListChecker" )
			if [ ! -z "$resultDNSQuery"  ];then
				finalResult="$finalResult\n""$domainBlackListChecker="$( dig TXT +time=10 +tries=1 +short "$reverseIP.$domainBlackListChecker" )
			fi
		fi

	done < "$fileBlackListChecker"
	
	echo -e $finalResult

}

while IFS= read -r ip
do
	if [[ $ip != \#* ]]; then
		ipMessage=$(checkBlackList "$ip")
		if [ ! -z "$ipMessage"  ];then
			finalMessage="$finalMessage\n$ip $ipMessage"			
		fi
	fi
done < "$fileIp"

if [[ ! -z $finalMessage ]];then
	printf "$finalMessage" | mail -s "Blacklist Checker" $email	
fi
