#!/bin/sh

sudo apt-get update
sudo apt-get upgrade -y
sudo apt update
sudo apt install software-properties-common  -y
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install python3.7  -y
sudo apt-add-repository ppa:ansible/ansible
sudo apt update
sudo apt-get install ansible -y
ansible -m ping localhost
echo "*******EVERYTHING IS INSTALLED*********"


