resource "aws_instance" "monitoring" {

  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id = var.subnet_id

  vpc_security_group_ids = [
    var.security_group_id
  ]

  key_name = var.key_name

  associate_public_ip_address = true

  user_data = <<-EOF
#!/bin/bash

# Update system
dnf update -y

# Install Grafana
dnf install -y https://dl.grafana.com/enterprise/release/grafana-enterprise-12.0.1-1.x86_64.rpm

systemctl daemon-reload
systemctl enable grafana-server
systemctl start grafana-server

# Install Prometheus
useradd --no-create-home --shell /bin/false prometheus

mkdir /etc/prometheus
mkdir /var/lib/prometheus

chown -R prometheus:prometheus /etc/prometheus
chown -R prometheus:prometheus /var/lib/prometheus

cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v3.5.0/prometheus-3.5.0.linux-amd64.tar.gz

tar -xvf prometheus-3.5.0.linux-amd64.tar.gz

cp prometheus-3.5.0.linux-amd64/prometheus /usr/local/bin/
cp prometheus-3.5.0.linux-amd64/promtool /usr/local/bin/

cat <<PROM >/etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]
PROM

cat <<SERVICE >/etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus

EOF

  tags = {
    Name = "${var.environment}-monitoring-server"
  }
}