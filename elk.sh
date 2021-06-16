#!/usr/bin/env bash
set -e

echo "Grabbing IPs..."
PRIVATE_IP=$(dig TXT +short o-o.myaddr.l.google.com @ns1.google.com)

echo "Installing dependencies..."
apt-get -qq update &>/dev/null
apt-get -yqq install unzip &>/dev/null
apt-get install dnsmasq

echo "Installing Docker..."
apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
apt update
apt-cache policy docker-ce
apt-get install docker-ce -y

tee /etc/consul.d/elk.json > /dev/null <<EOF
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

systemctl restart docker.service

systemctl daemon-reload
systemctl enable consul.service
systemctl start consul.service

systemctl restart docker.service
systemctl daemon-reload
systemctl start consul

docker pull docker.elastic.co/elasticsearch/elasticsearch:6.5.4
docker run -p 9300:9300 -p 9200:9200 -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" -e "discovery.type=single-node" --restart=always docker.elastic.co/elasticsearch/elasticsearch:6.5.4
