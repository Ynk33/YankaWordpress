#!/bin/bash

echo
echo "#####################################################"
echo "########### YANKAWORDPRESS SETUP SCRIPT #############"
echo "#####################################################"
echo

# Retrieving data
echo Retrieving data...

DIR=${PWD##*/}
DIR=${DIR:-/}

WP_CONTAINER=${DIR,,}-wordpress-1
DB_CONTAINER=${DIR,,}-db-1

IP_ADDRESS=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $DB_CONTAINER)

# Check if the Docker container is running, and stop the script if not, because otherwise the db cannot be dumped
if [ -z "${IP_ADDRESS}" ]
then
  echo
  echo -e "\033[31mCouldn't retrieve the database container IP address!\033[0m"
  echo This is more likely because the Docker container is not running.
  echo
  echo -e "\033[33mPlease, ensure the Docker container is running (\033[0mdocker compose up\033[33m) and launch this script again.\033[0m"
  echo

  exit 126;
fi

echo -e "- Wordpress container: \t\t\t\033[33m$WP_CONTAINER \033[0m"
echo -e "- Database container: \t\t\t\033[33m$DB_CONTAINER \033[0m"
echo -e "- Database container IP address: \t\033[33m$IP_ADDRESS \033[0m"

echo -e "\033[32mAll data ready! \033[0m"
echo

# Update the db.sh script to insert the Docker database container IP address
echo Updating db script...

sed -i -E "s|(IP_ADDRESS=).+|\1$IP_ADDRESS|g" db.sh

echo -e "\033[32mDone. \033[0m"
echo

# Dump the database from the Docker container
echo Executing db script on Docker container...

docker exec $WP_CONTAINER bash -c "bash < ./db.sh"

echo -e "\033[32mDone.\033[0m"
echo

# Revert the db.sh script, to leave no trace
echo Reverting db script...

sed -i -E "s|(IP_ADDRESS=).+|\1MY_IP|g" db.sh

echo -e "\033[32mDone. \033[0m"
echo

# Setup the git-hooks folder
echo Setting up Git hooks...

git config core.hookPath .hooks

echo -e "\033[32mDone. \033[0m"
echo

# All good!

echo -e "\033[32mYour \033[0m$DIR\033[32m project is all set up. Have fun! \033[0m"
echo

echo "#####################################################"
echo