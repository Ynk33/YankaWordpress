#!/bin/bash

echo
echo "#####################################################"
echo "########### YANKAWORDPRESS SETUP SCRIPT #############"
echo "#####################################################"
echo

echo Retrieving data...

DIR=${PWD##*/}
DIR=${DIR:-/}

WP_CONTAINER=${DIR,,}-wordpress-1
DB_CONTAINER=${DIR,,}-db-1

IP_ADDRESS=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $DB_CONTAINER)

echo -e "- Wordpress container: \t\t\t\033[33m$WP_CONTAINER \033[0m"
echo -e "- Database container: \t\t\t\033[33m$DB_CONTAINER \033[0m"
echo -e "- Database container IP address: \t\033[33m$IP_ADDRESS \033[0m"

echo -e "\033[32mAll data ready! \033[0m"
echo

echo Updating db script...

sed -i -E "s|(IP_ADDRESS=).+|\1$IP_ADDRESS|g" db.sh

echo -e "\033[32mDone. \033[0m"
echo

echo Executing db script on Docker container...

docker exec $WP_CONTAINER bash -c "bash < ./db.sh"

echo -e "\033[32mDone.\033[0m"
echo

echo -e "\033[32mYour \033[0m$DIR\033[32m project is all set up. Have fun! \033[0m"
echo

echo "#####################################################"
echo