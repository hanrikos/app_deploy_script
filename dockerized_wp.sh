#!/bin/bash

#echo $pass | su $user –c ‘ls /root’
#echo $pass | sudo -S ls /root
echo $pass | sudo -S ls /root

sudo sed -i "/127.0.0.1/ s/.*/0.0.0.0\tlocalhost/g" /etc/hosts

sudo git clone https://github.com/filipw01/wordpress-dockerized.git /tmp/deploy

sudo docker-compose up
