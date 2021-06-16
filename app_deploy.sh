#!/usr/bin/env bash
set -e

echo "Grabbing IPs..."
PRIVATE_IP=$(dig TXT +short o-o.myaddr.l.google.com @ns1.google.com)

echo "Installing dependencies..."
apt-get -qq update &>/dev/null
apt-get -yqq install unzip &>/dev/null
apt-get install dnsmasq

tee /tmp/filebeat.yml > /dev/null <<EOF
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
apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
apt update
apt-cache policy docker-ce
apt-get install docker-ce -y


systemctl restart docker.service

systemctl daemon-reload
systemctl enable consul.service
systemctl start consul.service

systemctl restart docker.service
docker pull hansmuller/midproject:latest
docker pull docker.elastic.co/beats/filebeat:6.5.4
docker run -p 65433:65433 -v /tmp:/tmp --restart always hansmuller/midproject:latest &

docker run -v /tmp/filebeat.yml:/usr/share/filebeat/filebeat.yml -v /tmp:/tmp:ro --restart=always docker.elastic.co/beats/filebeat:6.5.4 &

tee /tmp/logmaker.sh > /dev/null <<EOF
while :
do
    curl "localhost:65433" --output "/tmp/app_log.txt"
    sleep 5s
done
EOF
chmod +x /tmp/logmaker.sh
exec /tmp/logmaker.sh&
