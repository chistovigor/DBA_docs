#!/bin/bash

# MongoDB Exporter Installation Script
set -e

# Configuration
EXPORTER_VERSION="0.40.0"
EXPORTER_PORT="9216"
EXPORTER_USER="zabbix"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}MongoDB Exporter Installation Script${NC}"
echo "=========================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root${NC}"
    exit 1
fi

# Request password
read -s -p "Enter password for MongoDB user '$EXPORTER_USER': " MONGODB_PASSWORD
echo

# Download and install exporter
echo -e "${YELLOW}Downloading MongoDB Exporter...${NC}"
cd /tmp
wget -q "https://github.com/percona/mongodb_exporter/releases/download/v${EXPORTER_VERSION}/mongodb_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz"
tar xzf "mongodb_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz"
cp "mongodb_exporter-${EXPORTER_VERSION}.linux-amd64/mongodb_exporter" /usr/local/bin/
chmod +x /usr/local/bin/mongodb_exporter

# Create environment file
echo -e "${YELLOW}Creating configuration...${NC}"
cat > /etc/default/mongodb_exporter << EOF
MONGODB_URI=mongodb://${EXPORTER_USER}:${MONGODB_PASSWORD}@localhost:27017/?authSource=admin&tls=false
EOF
chmod 600 /etc/default/mongodb_exporter

# Create systemd service
echo -e "${YELLOW}Creating systemd service...${NC}"
cat > /etc/systemd/system/mongodb_exporter.service << EOF
[Unit]
Description=MongoDB Exporter
After=network.target
Wants=mongod.service

[Service]
User=mongodb
Group=mongodb
EnvironmentFile=/etc/default/mongodb_exporter
ExecStart=/usr/local/bin/mongodb_exporter \
  --mongodb.uri=\${MONGODB_URI} \
  --collector.diagnosticdata \
  --collector.replicasetstatus \
  --collector.topmetrics \
  --web.listen-address=0.0.0.0:${EXPORTER_PORT}
Restart=always
RestartSec=5
StartLimitInterval=0

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start service
echo -e "${YELLOW}Starting MongoDB Exporter...${NC}"
systemctl daemon-reload
systemctl enable mongodb_exporter
systemctl start mongodb_exporter

# Check if service is running
sleep 3
if systemctl is-active --quiet mongodb_exporter; then
    echo -e "${GREEN}MongoDB Exporter is running successfully${NC}"
else
    echo -e "${RED}Failed to start MongoDB Exporter${NC}"
    journalctl -u mongodb_exporter -n 10 --no-pager
    exit 1
fi

# Open firewall port if ufw is active
if command -v ufw >/dev/null 2>&1 && ufw status | grep -q "Status: active"; then
    echo -e "${YELLOW}Configuring firewall...${NC}"
    ufw allow ${EXPORTER_PORT}/tcp comment "MongoDB Exporter"
fi

# Cleanup
rm -rf "/tmp/mongodb_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz" "/tmp/mongodb_exporter-${EXPORTER_VERSION}.linux-amd64"

echo -e "${GREEN}Installation completed successfully!${NC}"
echo -e "MongoDB Exporter is listening on port: ${EXPORTER_PORT}"
echo -e "Check metrics: curl http://localhost:${EXPORTER_PORT}/metrics"
echo -e "Service status: systemctl status mongodb_exporter"
