#!/usr/bin/env bash

#this is the directory the script is running in
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

######Docker Build  and Versioning#########
## This section just decides what version of the docker image to build or run
## it decides this by the last time the Dockerfile or the requirements.txt were
## modified. Which ever was later is the version number we use
##
## Then if the image doesn't exist we create it
##
########################

#Get the date the Docker File and requirements file was last edited
dcdate=$(stat -c "%Y"  Dockerfile)
reqdate=$(stat -c "%Y" requirements.txt)


#If requirements were modified after the Dockerfile use that date instead
if [ "$reqdate" -gt  "$dcdate" ]
then
	dcdate="$reqdate"
fi

#echo "$dcdate"

#if [[ "$(docker images -q qbswebserver:$dcdate 2> /dev/null)" == "" ]]; then
if [ -z $(docker images -q qbswebserver:$dcdate) ]; then
	echo "Docker Image qbswebserver:$dcdate does not exist, time to create it"
	#out with the old (delete the old versions of this image locally)
	if [[ $(docker images -a | grep "qbswebserver" | awk '{print $3}') ]]; then
		echo "Docker images that need deleted:"
		echo "$(docker images -a | grep "qbswebserver" | awk '{print $3}')"
		docker images -a | grep "qbswebserver" | awk '{print $3}' | xargs docker rmi -f
	else
		echo "No old Dockers to delete... moving right along"
	fi
	#in with the new
	echo "Building Docker image qbswebserver:$dcdate"
	docker image build -t qbswebserver:$dcdate -f "$DIR/Dockerfile" .
else
	echo "Docker Image qbswebserver:$dcdate already exists, no need to recreate it"
fi


######Run me#########

#tar up the .aws and .ssh dirs
tar -cvzf awscreds.tgz $HOME/.aws
tar -cvzf ssh.tgz $HOME/.aws_ssh

#set up the pathcount for unzipping on the other side of the lookin glass
HOME=${HOME%/}
PATHCONTEXT=${HOME//[!\/]}
PATHCOUNT=${#PATHCONTEXT}
echo "$PATHCOUNT">pathcount.txt



#-v mounts a volume
#-rm removes the container when done
#-i -t interactive mode for bash
#bash at the end tells it to put us in a shell
echo $DIR
docker run  -v $DIR/src:/root/src  -i -t qbswebserver:$dcdate bash 

rm awscreds.tgz
rm ssh.tgz


#TODO: once this is all built we will change from going to a shell to having an entry point script that just runs




