#!/usr/bin/sudo bash

set -e

echo "Grabbing IPs..."
PRIVATE_IP=$(dig TXT +short o-o.myaddr.l.google.com @ns1.google.com)

echo "Installing dependencies..."
sudo apt-get -qq update &>/dev/null
sudo apt-get -yqq install unzip &>/dev/null
sudo apt-get install dnsmasq

sudo tee /tmp/kibana.yml > /dev/null <<"EOF"
---
server.name: kibana
server.host: "0.0.0.0"
elasticsearch.url: "PRIVATE_IP:9200"
EOF

echo "Installing Docker..."
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
sudo apt-cache policy docker-ce
sudo apt-get install docker-ce -y

sudo systemctl restart docker.service

sudo systemctl daemon-reload

sudo docker pull docker.elastic.co/kibana/kibana:6.5.4
sudo docker run -p 5601:5601 -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" -v /tmp/kibana.yml:/usr/share/kibana/config/kibana.yml --restart=always docker.elastic.co/kibana/kibana:6.5.4
