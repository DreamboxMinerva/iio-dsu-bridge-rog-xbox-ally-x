#!/usr/bin/env bash
set -e

# Installer for iio-dsu-bridge
# Supports ROG Ally, ROG Xbox Ally X and Legion Go S.

SERVICE_NAME="iio-dsu-bridge"
BIN_DIR="$HOME/.local/bin"
BIN_PATH="$BIN_DIR/iio-dsu-bridge"
CONFIG_DIR="$HOME/.config"
CONFIG_FILE="$CONFIG_DIR/iio-dsu-bridge.yaml"
SERVICE_FILE="$CONFIG_DIR/systemd/user/${SERVICE_NAME}.service"

# Release assets from this fork
RELEASE_URL="https://github.com/DreamboxMinerva/iio-dsu-bridge-rog-xbox-ally-x/releases/latest/download"

echo "============================================"
echo "  iio-dsu-bridge Installer"
echo "============================================"
echo ""

if ! command -v curl >/dev/null 2>&1; then
    echo "error: curl is required" >&2
    exit 1
fi

if ! [ -t 0 ]; then
    echo "This installer requires interactive input."
    echo ""
    echo "Please run:"
    echo ""
    echo "  bash <(curl -fsSL ${RELEASE_URL}/install.sh)"
    echo ""
    exit 1
fi

echo "==> Select your device:"
echo "  1) ROG Ally"
echo "  2) ROG Xbox Ally X"
echo "  3) Legion Go S"
echo ""

read -p "Enter choice [1-3]: " DEVICE_CHOICE

case "$DEVICE_CHOICE" in
    1)
        CONFIG_URL="${RELEASE_URL}/rog-ally.yaml"
        DEVICE_NAME="ROG Ally"
        RATE=250
        ;;
    2)
        CONFIG_URL="${RELEASE_URL}/rog-xbox-ally-x.yaml"
        DEVICE_NAME="ROG Xbox Ally X"
        RATE=200
        ;;
    3)
        CONFIG_URL="${RELEASE_URL}/legion-go-s.yaml"
        DEVICE_NAME="Legion Go S"
        RATE=250
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo ""
echo "==> Installing for: $DEVICE_NAME"
echo "==> Sensor rate: ${RATE} Hz"
echo ""

echo "==> Creating required folders..."
mkdir -p "$BIN_DIR"
mkdir -p "$CONFIG_DIR"
mkdir -p "$(dirname "$SERVICE_FILE")"

echo "==> Downloading binary..."
curl -fL "${RELEASE_URL}/iio-dsu-bridge" -o "$BIN_PATH"
chmod +x "$BIN_PATH"

echo "==> Downloading config for $DEVICE_NAME..."
curl -fL "$CONFIG_URL" -o "$CONFIG_FILE"

echo "==> Downloading uninstaller to Desktop..."
DESKTOP_DIR="$HOME/Desktop"
mkdir -p "$DESKTOP_DIR"

curl -fL \
    "${RELEASE_URL}/uninstall-iio-dsu-bridge.desktop" \
    -o "$DESKTOP_DIR/uninstall-iio-dsu-bridge.desktop"

chmod +x "$DESKTOP_DIR/uninstall-iio-dsu-bridge.desktop"

echo "==> Writing user service..."
cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=IIO to DSU Bridge for Gyro/Motion Controls ($DEVICE_NAME)
After=default.target

[Service]
Type=simple
ExecStart=$BIN_PATH --rate=$RATE --log-every=0
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
EOF

echo "==> Reloading systemd user daemon..."
systemctl --user daemon-reload

echo "==> Enabling and starting service..."
systemctl --user enable --now "${SERVICE_NAME}.service" || {
    echo ""
    echo "Failed to start the service."
    echo ""
    echo "Try:"
    echo "  systemctl --user daemon-reload"
    echo "  systemctl --user enable --now ${SERVICE_NAME}.service"
    exit 1
}

if command -v loginctl >/dev/null 2>&1; then
    echo "==> Enabling user service auto-start..."
    sudo loginctl enable-linger "$USER" 2>/dev/null || true
fi

echo ""
echo "============================================"
echo "  Installation complete!"
echo "============================================"
echo ""
echo "Device:      $DEVICE_NAME"
echo "Rate:        ${RATE} Hz"
echo "Config:      $CONFIG_FILE"
echo "Binary:      $BIN_PATH"
echo "Service:     $SERVICE_FILE"
echo ""
echo "DSU server:  127.0.0.1:26760"
echo ""
echo "View logs with:"
echo "  journalctl --user -u ${SERVICE_NAME} -f"
echo ""
echo "To uninstall, use the uninstaller on your Desktop."
