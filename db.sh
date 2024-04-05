#!/bin/bash


IP_ADDRESS=MY_IP

mysql -h $IP_ADDRESS -u wordpress -pwordpress -Nse 'show tables' wordpress | while read table; do mysql -h $IP_ADDRESS -u wordpress -pwordpress -e "TRUNCATE TABLE $table" wordpress; done
mysql -h $IP_ADDRESS -u wordpress -pwordpress wordpress < dump_full.sql