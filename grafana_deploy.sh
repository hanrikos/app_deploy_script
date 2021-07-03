#!/bin/bash

# get credentials from params


echo $pass | sudo -S ls /root

sudo sed -i "/127.0.0.1/ s/.*/0.0.0.0\tlocalhost/g" /etc/hosts


# Download grafana
wget https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana_4.6.3_amd64.deb

# Install grafana
sudo apt-get install -y adduser libfontconfig
sudo dpkg -i grafana_4.6.3_amd64.deb

# systemd
sudo systemctl daemon-reload
sudo systemctl enable grafana-server
sudo systemctl start grafana-server

# Installation cleanup
rm grafana_4.6.3_amd64.deb
