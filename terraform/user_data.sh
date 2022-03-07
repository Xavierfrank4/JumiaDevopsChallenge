#!/bin/bash

apt-get update
apt-get install apt-transport-https wget gnupg
apt-add-repository ppa:ansible/ansible
apt-get update
apt-get install ansible

sudo sed -i 's/22/${ssh_port}/g' /etc/ssh/sshd_config
sudo service ssh restart
