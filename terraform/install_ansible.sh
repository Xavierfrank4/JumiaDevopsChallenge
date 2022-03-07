#!/bin/bash

apt-get update
apt-get install apt-transport-https wget gnupg
apt-add-repository ppa:ansible/ansible
apt-get update
apt-get install ansible
