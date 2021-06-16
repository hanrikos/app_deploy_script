#!/usr/bin/env bash
set -e

echo "Grabbing IPs..."
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

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

sudo tee /etc/consul.d/elk.json > /dev/null <<EOF
{"service": {
    "name": "elk",
    "tags": ["elk"],
    "port": 9200,
    "check": {
        "http": "http://localhost:9200/_cluster/health",
        "interval": "10s"
        }
    }
}
EOF

sudo systemctl restart docker.service

sudo systemctl daemon-reload
sudo systemctl enable consul.service
sudo systemctl start consul.service

sudo systemctl restart docker.service
systemctl daemon-reload
systemctl start consul

sudo docker pull docker.elastic.co/elasticsearch/elasticsearch:6.5.4
sudo docker run -p 9300:9300 -p 9200:9200 -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" -e "discovery.type=single-node" --restart=always docker.elastic.co/elasticsearch/elasticsearch:6.5.4
