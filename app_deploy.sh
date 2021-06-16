#!/usr/bin/sudo bash
set -e

echo "Grabbing IPs..."
PRIVATE_IP=$(dig TXT +short o-o.myaddr.l.google.com @ns1.google.com)

echo "Installing dependencies..."
sudo apt-get -qq update &>/dev/null
sudo apt-get -yqq install unzip &>/dev/null
sudo apt-get install dnsmasq

sudo tee /tmp/filebeat.yml > /dev/null <<EOF
filebeat.prospectors:
- type: log
  enabled: true
  paths:
    - "/tmp/app_log.txt"
setup.kibana:
  host: "PRIVATE_IP:5601"
output.elasticsearch:
  hosts: ["PRIVATE_IP:9200"]
  index: "filebeat-$PRIVATE_IP-%%{+yyyy.MM.dd}"
setup.template.name: "$PRIVATE_IP"
setup.template.pattern: "$PRIVATE_IP-*-Pattern"
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
