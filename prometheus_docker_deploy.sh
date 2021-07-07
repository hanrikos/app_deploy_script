#!/bin/bash

#echo $pass | su $user –c ‘ls /root’
#echo $pass | sudo -S ls /root
echo $pass | sudo -S ls /root

sudo sed -i "/127.0.0.1/ s/.*/0.0.0.0\tlocalhost/g" /etc/hosts

sudo tee /tmp/prometheus.yml > /dev/null <<"EOF"
global:
  scrape_interval: 15s
rule_files:
  - 'prometheus.rules.yml'
scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
      - targets: ['0.0.0.0:9090']
  - job_name: 'grafana'
    scrape_interval: 5s
    static_configs:
      - targets:
        - $GRAFANA_IP:3000
EOF

# systemd
sudo systemctl daemon-reload

sudo systemctl restart docker.service
sudo docker pull prom/prometheus
sudo docker run -p 9090:9090 -v /tmp/prometheus.yml:/etc/prometheus/prometheus.yml --restart=always prom/prometheus
