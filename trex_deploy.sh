#!/bin/bash

#echo $pass | su $user –c ‘ls /root’
#echo $pass | sudo -S ls /root
echo $pass | sudo -S ls /root

sudo sed -i "/127.0.0.1/ s/.*/0.0.0.0\tlocalhost/g" /etc/hosts

wget -qO- https://get.docker.com/ | sh

sudo git clone https://github.com/hanrikos/app_deploy_script.git /tmp/deploy
cd /tmp/deploy/trex
sudo docker build -t trex-dev-ubuntu:16.04 .
sudo docker run -it --privileged --cap-add=ALL -v /mnt/huge:/mnt/huge -v /sys/bus/pci/devices:/sys/bus/pci/devices -v /sys/devices/system/node:/sys/devices/system/node -v /dev:/dev trex-dev-ubuntu:16.04
