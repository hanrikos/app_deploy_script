#!/bin/bash
if [ $SCRIPT_MODE = "full" ]; then
  #echo $pass | su $user –c ‘ls /root’
  #echo $pass | sudo -S ls /root
  echo $pass | sudo -S ls /root

  sudo sed -i "/127.0.0.1/ s/.*/0.0.0.0\tlocalhost/g" /etc/hosts

  # Make prometheus user
  sudo adduser --no-create-home --disabled-login --shell /bin/false --gecos "Prometheus Monitoring User" prometheus

  # Make directories and dummy files necessary for prometheus
  sudo mkdir /etc/prometheus
  sudo mkdir /var/lib/prometheus
  sudo touch /etc/prometheus/prometheus.yml
  sudo touch /etc/prometheus/prometheus.rules.yml

  # Assign ownership of the files above to prometheus user
  sudo chown -R prometheus:prometheus /etc/prometheus
  sudo chown prometheus:prometheus /var/lib/prometheus

  # Download prometheus and copy utilities to where they should be in the filesystem
  #VERSION=2.2.1
  VERSION=$(curl https://raw.githubusercontent.com/prometheus/prometheus/master/VERSION)
  wget https://github.com/prometheus/prometheus/releases/download/v${VERSION}/prometheus-${VERSION}.linux-amd64.tar.gz
  tar xvzf prometheus-${VERSION}.linux-amd64.tar.gz

  sudo cp prometheus-${VERSION}.linux-amd64/prometheus /usr/local/bin/
  sudo cp prometheus-${VERSION}.linux-amd64/promtool /usr/local/bin/
  sudo cp -r prometheus-${VERSION}.linux-amd64/consoles /etc/prometheus
  sudo cp -r prometheus-${VERSION}.linux-amd64/console_libraries /etc/prometheus

  # Assign the ownership of the tools above to prometheus user
  sudo chown -R prometheus:prometheus /etc/prometheus/consoles
  sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
  sudo chown prometheus:prometheus /usr/local/bin/prometheus
  sudo chown prometheus:prometheus /usr/local/bin/promtool

  # Get yaml files externally
  #sudo git clone https://github.com/hanrikos/app_deploy_script.git /tmp/deploy

  # Populate configuration files
  #cat /tmp/deploy/prometheus/prometheus.yml | sudo tee /etc/prometheus/prometheus.yml
  #cat /tmp/deploy/prometheus/prometheus.rules.yml | sudo tee /etc/prometheus/prometheus.rules.yml
  #cat /tmp/deploy/prometheus/prometheus.service | sudo tee /etc/systemd/system/prometheus.service

  sudo tee /etc/prometheus/prometheus.rules.yml > /dev/null <<EOF
  groups:
    - name: example_alert
      rules:
        - alert: InstanceDown
          expr: up == 0
          for: 5m
          labels:
            severity: page
          annotations:
            summary: "Instance {{ $labels.instance }} down"
            description: "{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 5 minutes."
  EOF

  sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOF
  [Unit]
  Description=Prometheus
  Wants=network-online.target
  After=network-online.target

  [Service]
  User=prometheus
  Group=prometheus
  Type=simple
  ExecStart=/usr/local/bin/prometheus --config.file /etc/prometheus/prometheus.yml --storage.tsdb.path /var/lib/prometheus/ --web.console.templates=/etc/prometheus/consoles --web.console.libraries=/etc/prometheus/console_libraries

  [Install]
  WantedBy=multi-user.target
  EOF

  # 'sudo sed -i "s/\\bgrafana_ip_in_yml\\b/$GRAFANA_IP/g" /etc/prometheus/prometheus.yml'
  sudo tee /etc/prometheus/prometheus.yml > /dev/null <<EOF
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
  sudo systemctl enable prometheus
  sudo systemctl start prometheus

  # Installation cleanup
  rm prometheus-${VERSION}.linux-amd64.tar.gz
  rm -rf prometheus-${VERSION}.linux-amd64
  # sudo rm -rf /tmp/deploy

elif [ $SCRIPT_MODE = "config_only" ]; then
  sudo tee /etc/prometheus/prometheus.yml > /dev/null <<EOF
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
  sudo systemctl restart prometheus
else
  echo "try again"
fi
