#!/bin/bash
sudo perl -pi -e 's/^#?Port 22$/Port 1337/' /etc/ssh/sshd_config
sudo service sshd restart 
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible