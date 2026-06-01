#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="webssh"
RUN_USER="bkbest21"
PORT="8888"
CONFIG_FILE="/home/${RUN_USER}/webssh.conf"

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if the specified user exists
if ! id "$RUN_USER" &>/dev/null; then
  echo "User '$RUN_USER' does not exist. Creating user..."
  useradd -m -s /bin/bash "$RUN_USER"
  echo "Created user '$RUN_USER'"
fi

# Install WebSSH
echo "Installing WebSSH..."
pip3 install webssh

# Copy WebSSH configuration file
echo "Copying WebSSH configuration file..."
sudo cp "$APP_DIR/webssh.conf" "$CONFIG_FILE"

# Set proper permissions
echo "Setting permissions..."
chown -R "$RUN_USER:$RUN_USER" "$CONFIG_FILE"
chmod 644 "$CONFIG_FILE"

# Create systemd service file
UNIT_PATH="/etc/systemd/system/${SERVICE_NAME}.service"

sudo tee "$UNIT_PATH" >/dev/null <<EOF
[Unit]
Description=WebSSH Service
After=network.target

[Service]
Type=simple
User=${RUN_USER}
WorkingDirectory=/home/${RUN_USER}
ExecStart=/usr/local/bin/wssh --config=${CONFIG_FILE}
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Set proper permissions for service file
chmod 644 "$UNIT_PATH"

# Reload systemd, enable and start the service
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

echo "Enabling service..."
sudo systemctl enable "${SERVICE_NAME}.service"

echo "Starting service..."
# Test service start with better error handling
if sudo systemctl start "${SERVICE_NAME}.service" 2>&1; then
  echo "✓ Service start command executed"
  sleep 3
  if sudo systemctl is-active --quiet "${SERVICE_NAME}.service"; then
    echo "✓ Service is running successfully"
  else
    echo "⚠ Service started but may have stopped"
    echo "Recent logs:"
    sudo journalctl -u "${SERVICE_NAME}.service" --no-pager -n 15
  fi
else
  echo "✗ Service failed to start"
  echo "Service logs:"
  sudo journalctl -u "${SERVICE_NAME}.service" --no-pager -n 15
fi

echo ""
echo "=========================================="
echo "Deployment completed successfully!"
echo "=========================================="
echo "Service: ${SERVICE_NAME}.service"
echo "User: ${RUN_USER}"
echo "Port: ${PORT}"
echo "Config File: ${CONFIG_FILE}"
echo ""
echo "Service management commands:"
echo "  Status: sudo systemctl status ${SERVICE_NAME}.service"
echo "  Logs: sudo journalctl -u ${SERVICE_NAME}.service -f"
echo "  Restart: sudo systemctl restart ${SERVICE_NAME}.service"
echo "  Stop: sudo systemctl stop ${SERVICE_NAME}.service"
echo "  Start: sudo systemctl start ${SERVICE_NAME}.service"
echo ""
echo "To access WebSSH, open: http://$(hostname -I | awk '{print $1}'):${PORT}"
echo "=========================================="