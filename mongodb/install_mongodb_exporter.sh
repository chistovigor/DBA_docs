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
  --collector.dbstats \
  --collector.dbstatsfreestorage \
  --collector.topmetrics \
  --collector.currentopmetrics \
  --collector.indexstats \  
  --collector.collstats \
  --collector.profile \
  --discovering-mode \
  --compatible-mode \
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

# Find nftables config files
CONFIG_FILES=(
    "/etc/nftables.conf"
    "/etc/nftables/ipv4-filter.nft" 
    "/etc/nftables/ipv6-filter.nft"
    "/etc/nftables.nft"
)

for config_file in "${CONFIG_FILES[@]}"; do
    if [ -f "$config_file" ]; then
        echo "Found config file: $config_file"
        
        # Check if port already exists
        if grep -q "elements = {.*${EXPORTER_PORT}.*}" "$config_file"; then
            echo "Port ${EXPORTER_PORT} already exists in $config_file"
        else
            # Add port to firewall_open_tcp_ports set
            sed -i '/set firewall_open_tcp_ports {/,/}/ {
                /elements = {/ {
                    s/elements = { \(.*\) }/elements = { \1, '"${EXPORTER_PORT}"' }/
                }
            }' "$config_file"
            echo "Port ${EXPORTER_PORT} added to $config_file"
        fi
    fi
done

# Restart nftables
systemctl restart nftables

# Verify
if nft list ruleset | grep -q "${EXPORTER_PORT}"; then
    echo "SUCCESS: Port ${EXPORTER_PORT} is now open in nftables"
else
    echo "WARNING: Port ${EXPORTER_PORT} not found in nftables ruleset"
    echo "Current rules:"
    nft list ruleset | grep -A5 -B5 "tcp"
fi

# Cleanup
rm -rf "/tmp/mongodb_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz" "/tmp/mongodb_exporter-${EXPORTER_VERSION}.linux-amd64"

echo -e "${GREEN}Installation completed successfully!${NC}"
echo -e "MongoDB Exporter is listening on port: ${EXPORTER_PORT}"
echo -e "Check metrics: curl http://localhost:${EXPORTER_PORT}/metrics"
echo -e "Service status: systemctl status mongodb_exporter"
