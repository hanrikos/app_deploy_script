#!/usr/bin/env bash
set -e

echo "Grabbing IPs..."
PRIVATE_IP=$(dig TXT +short o-o.myaddr.l.google.com @ns1.google.com)

echo "Installing dependencies..."
apt-get -qq update &>/dev/null
apt-get -yqq install unzip &>/dev/null
apt-get install dnsmasq

tee /tmp/kibana.yml > /dev/null <<"EOF"
---
server.name: kibana
server.host: "0.0.0.0"
elasticsearch.url: "PRIVATE_IP:9200"
EOF

echo "Installing Docker..."
apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
apt update
apt-cache policy docker-ce
apt-get install docker-ce -y

systemctl restart docker.service

systemctl daemon-reload

docker pull docker.elastic.co/kibana/kibana:6.5.4
docker run -p 5601:5601 -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" -v /tmp/kibana.yml:/usr/share/kibana/config/kibana.yml --restart=always docker.elastic.co/kibana/kibana:6.5.4
