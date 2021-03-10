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
ansible-galaxy install systemli.spamassassin
ansible-galaxy install oefenweb.fail2ban
ansible-galaxy install geerlingguy.apache
git clone https://github.com/hightekvagabond/QBSWebServer.git --branch webmail_playbook
#git clone https://github.com/dami0/QBSWebServer.git --branch webmail_playbook
ansible -m ping localhost

# removal of "this" script from target
rm /home/ubuntu/install_ansible.sh
echo "*******EVERYTHING IS INSTALLED*********"

ansible-playbook /home/ubuntu/QBSWebServer/ansible/update_from_git.yml
sudo reboot
