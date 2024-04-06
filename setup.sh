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

read -p "What is the name of the project?    " -i "${DIR,,}" -e PROJECT_NAME
echo -e "\033[32m$PROJECT_NAME\033[0m"
echo

read -p "What is the name of the repo on Github?    " -i "$PROJECT_NAME" -e REPO_NAME
echo -e "\033[32m$PROJECT_NAME\033[0m"
echo

echo -e "- Wordpress container: \t\t\t\033[33m$WP_CONTAINER \033[0m"
echo -e "- Database container: \t\t\t\033[33m$DB_CONTAINER \033[0m"
echo -e "- Database container IP address: \t\033[33m$IP_ADDRESS \033[0m"
echo -e "- The repo will be stored at \t\tgithub.com:Ynk33/\033[33m$REPO_NAME\033[0m"
echo

read -p "Do you confirm that these informations are correct? (y/n) " -n 1 -r
echo
echo

# Check the reply value
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
  echo -e "\033[31mOops!"
  echo -e "\033[33mNo worries. You can check these informations again and safely launch this script when you're ready to set this project up! \033[31m<3\033[0m"
  echo  
  [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi

echo -e "\033[32mAll data ready! \033[0m"
echo

# Creating github environment
echo Login into your Github account...
gh auth login --with-token < C:/Users/ytira/.github/token.txt

echo Checking if repo already exists...
REPO_LIST=$(gh repo list)
if echo "$REPO_LIST" | grep -qi "$REPO_NAME"
then
  echo Repo exists, skipping creation.
else
  echo Repo does not exist, creating it...
  gh repo create $REPO_NAME --private --source=.
fi

echo Updating origin...
git remote set-url origin git@github.com:Ynk33/$REPO_NAME

echo Creating main branch...
git branch main
git checkout main
git add .
git commit -m "First commit, project setup"
git push --no-verify -u origin main
echo

echo Creating develop branch...
git branch develop
git checkout develop
git merge main
git push --no-verify -u origin develop

git checkout main

echo
echo -e "\033[32mDone. \033[0m"
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

git checkout -- db.sh

echo -e "\033[32mDone. \033[0m"
echo

# Setup the git-hooks folder
echo Setting up Git hooks...

git config core.hooksPath .hooks

echo -e "\033[32mDone. \033[0m"
echo

# All good!

echo -e "\033[32mYour \033[0m$DIR\033[32m project is all set up.\033[0m"
echo

echo -e "2 branches have been set up in your git repository:"
echo -e "\033[33mmain\033[0m is the main branch from which each new feature should start."
echo -e "\tPushing on this branch will trigger the deployment in production."
echo -e "\033[33mdevelop\033[0m is the development branch on which to merge completed new features."
echo -e "\tPushing on this branch will trigger the deployment in pre-production."
echo -e "\tWhen new features are tested on this branch and ready to be deployed in production, \033[33mdevelop\033[0m can be merged on \033[33mmain\033[0m and pushed."
echo

echo -e "\t\033[32mHave fun! \033[0m"

echo "#####################################################"
echo