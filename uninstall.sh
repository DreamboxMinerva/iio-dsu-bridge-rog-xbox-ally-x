#!/usr/bin/env bash
set -e

# Uninstaller for iio-dsu-bridge
# Removes the binary, config file, and systemd service

SERVICE_NAME="iio-dsu-bridge"
BIN_PATH="$HOME/.local/bin/iio-dsu-bridge"
CONFIG_FILE="$HOME/.config/iio-dsu-bridge.yaml"
SERVICE_FILE="$HOME/.config/systemd/user/${SERVICE_NAME}.service"
DESKTOP_FILE="$HOME/Desktop/uninstall-iio-dsu-bridge.desktop"

echo "============================================"
echo "  iio-dsu-bridge Uninstaller"
echo "============================================"
echo ""

echo "==> Stopping and disabling service..."
systemctl --user disable --now "${SERVICE_NAME}.service" 2>/dev/null || true

echo "==> Removing files..."
rm -f "$SERVICE_FILE"
rm -f "$BIN_PATH"
rm -f "$CONFIG_FILE"
rm -f "$DESKTOP_FILE"

echo "==> Reloading systemd user daemon..."
systemctl --user daemon-reload 2>/dev/null || true

echo ""
echo "============================================"
echo "  Uninstall complete!"
echo "============================================"
echo ""
echo "Removed:"
echo "  - $BIN_PATH"
echo "  - $CONFIG_FILE"
echo "  - $SERVICE_FILE"
echo "  - $DESKTOP_FILE"

