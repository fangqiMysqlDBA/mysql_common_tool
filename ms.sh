#!/bin/bash

ip_port=$1
ip=$(echo $ip_port|awk -F: '{print $1}')
port=$(echo $ip_port|awk -F: '{print $2}')
perl orzdba -H $ip -P $port -com -innodb_rows -t  -innodb_log -B -T 
