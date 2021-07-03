#!/bin/bash

#echo $pass | su $user –c ‘ls /root’
#echo $pass | sudo -S ls /root
echo $pass | sudo -S ls /root

sudo sed -i "/127.0.0.1/ s/.*/0.0.0.0\tlocalhost/g" /etc/hosts

sudo git clone https://github.com/petarGitNik/prometheus-install.git /tmp/deploy

sudo chmod +x /tmp/deploy/full_installation.sh
cd /tmp/deploy
sudo bash full_installation.sh
