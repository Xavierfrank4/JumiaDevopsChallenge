#!/bin/bash
sudo perl -pi -e 's/^#?Port 22$/Port 1337/' /etc/ssh/sshd_config
sudo service sshd restart 
