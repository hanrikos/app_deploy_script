#!/usr/bin/env bash
set -e

echo "Grabbing IPs..."
PRIVATE_IP="192.168.42.177"

echo "Installing dependencies..."
sudo apt-get -qq update &>/dev/null
sudo apt-get -yqq install unzip &>/dev/null
sudo apt-get install dnsmasq

echo "Installing Docker..."
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
sudo apt-cache policy docker-ce
sudo apt-get install docker-ce -y


sudo systemctl restart docker.service

sudo systemctl daemon-reload

sudo systemctl restart docker.service
systemctl daemon-reload

sudo docker pull docker.elastic.co/elasticsearch/elasticsearch:6.5.4
sudo docker run -p 9300:9300 -p 9200:9200 -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" -e "discovery.type=single-node" --restart=always docker.elastic.co/elasticsearch/elasticsearch:6.5.4
