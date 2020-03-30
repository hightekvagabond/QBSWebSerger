#!/usr/local/bin/bash

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
dcdate=$(stat -f "%Sm" -t "%Y%m%d%H%M%S"  Dockerfile)
reqdate=$(stat -f "%Sm" -t "%Y%m%d%H%M%S"  requirements.txt)

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
	docker images -a | grep "qbswebserver" | awk '{print $3}' | xargs docker rmi -f
	#in with the new
	docker image build -t qbswebserver:$dcdate .
else
	echo "Docker Image qbswebserver:$dcdate already exists, no need to recreate it"
fi


######Run me#########

#-v mounts a volume
#-rm removes the container when done
#-i -t interactive mode for bash
#bash at the end tells it to put us in a shell
docker run -v ~/.aws:/root/.aws -v ~/.ssh:/root/.ssh  -v $DIR/src:/root/src --rm   -i -t qbswebserver:$dcdate bash 


#TODO: once this is all built we will change from going to a shell to having an entry point script that just runs




