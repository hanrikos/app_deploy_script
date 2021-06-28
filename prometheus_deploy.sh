#!/usr/bin/env bash
set -e

echo "Installing dependencies..."
sudo apt-get -qq update &>/dev/null
sudo apt-get -yqq install unzip &>/dev/null

echo "Installing Docker..."
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
sudo apt-cache policy docker-ce
sudo apt-get install docker-ce -y

sudo systemctl restart docker.service

sudo tee /tmp/prometheus.yml > /dev/null <<"EOF"
global:
  scrape_interval:     10s
  evaluation_interval: 10s
rule_files:
  # - "first.rules"
  # - "second.rules"
scrape_configs:
  - job_name: prometheus
    static_configs:
      - targets: ['localhost:9090']
EOF

sudo systemctl daemon-reload

sudo systemctl restart docker.service
sudo docker pull prom/prometheus
sudo docker run -p 9090:9090 -v /tmp/prometheus.yml:/etc/prometheus/prometheus.yml --restart=always prom/prometheus
