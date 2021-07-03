#!/usr/bin/env bash

# get credentials from params


runAsRoot="
printf \"\nhey there\n\"
printf \"\nhello world, I am root\n\" >> \"/home/parallels/rootWasHere.txt\"
"
exec su root -c "$runAsRoot"

echo $pass | exec su $user –c ‘ls /root’

sudo apt-get install -y apt-transport-https
sudo apt-get install -y software-properties-common wget
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -

echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
sudo apt-get update
sudo apt-get install grafana

sudo systemctl daemon-reload
sudo systemctl start grafana-server
sudo systemctl status grafana-server

sudo systemctl enable grafana-server.service
