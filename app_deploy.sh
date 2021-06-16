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


sudo systemctl restart docker.service

sudo systemctl daemon-reload
sudo systemctl enable consul.service
sudo systemctl start consul.service

sudo systemctl restart docker.service
sudo docker pull hansmuller/midproject:latest
sudo docker pull docker.elastic.co/beats/filebeat:6.5.4
sudo docker run -p 65433:65433 -v /tmp:/tmp --restart always hansmuller/midproject:latest &

sudo docker run -v /tmp/filebeat.yml:/usr/share/filebeat/filebeat.yml -v /tmp:/tmp:ro --restart=always docker.elastic.co/beats/filebeat:6.5.4 &

sudo tee /tmp/logmaker.sh > /dev/null <<EOF
while :
do
    curl "localhost:65433" --output "/tmp/app_log.txt"
    sleep 5s
done
EOF
sudo chmod +x /tmp/logmaker.sh
exec /tmp/logmaker.sh&
