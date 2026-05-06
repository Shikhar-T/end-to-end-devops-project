#!/bin/bash

# Update packages
sudo apt update -y

# -----------------------------
# PROMETHEUS INSTALLATION
# -----------------------------

# Create Prometheus user/group
sudo groupadd --system prometheus || true

sudo useradd -s /sbin/nologin --system -g prometheus prometheus || true

# Create directories
sudo mkdir -p /etc/prometheus
sudo mkdir -p /var/lib/prometheus

# Set ownership
sudo chown -R prometheus:prometheus /etc/prometheus

sudo chown -R prometheus:prometheus /var/lib/prometheus

# Download Prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.53.0/prometheus-2.53.0.linux-amd64.tar.gz

tar -xvf prometheus-2.53.0.linux-amd64.tar.gz

cd prometheus-2.53.0.linux-amd64

# Copy binaries
sudo cp prometheus promtool /usr/local/bin/

# Copy config files
sudo cp -r consoles console_libraries /etc/prometheus/

sudo cp prometheus.yml /etc/prometheus/

# Set ownership again after copy
sudo chown -R prometheus:prometheus /etc/prometheus

sudo chown -R prometheus:prometheus /var/lib/prometheus

# Create Prometheus service
sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
sudo systemctl daemon-reload

# Enable/start Prometheus
sudo systemctl enable prometheus

sudo systemctl start prometheus

# -----------------------------
# NODE EXPORTER INSTALLATION
# -----------------------------

wget https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux-amd64.tar.gz

tar -xvf node_exporter-1.8.1.linux-amd64.tar.gz

cd node_exporter-1.8.1.linux-amd64

# Copy binary
sudo cp node_exporter /usr/local/bin/

# Create service
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=ubuntu
Group=ubuntu
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target
EOF

# Reload systemd
sudo systemctl daemon-reload

# Enable/start Node Exporter
sudo systemctl enable node_exporter

sudo systemctl start node_exporter

# -----------------------------
# GRAFANA INSTALLATION
# -----------------------------

sudo apt-get install -y adduser libfontconfig1 musl

wget https://dl.grafana.com/enterprise/release/grafana-enterprise_11.1.0_amd64.deb

sudo dpkg -i grafana-enterprise_11.1.0_amd64.deb

# Enable/start Grafana
sudo systemctl daemon-reload

sudo systemctl enable grafana-server

sudo systemctl start grafana-server
