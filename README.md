# iio-dsu-bridge

IIO → DSU (Cemuhook) motion bridge for Linux handhelds.

This fork adds **ROG Xbox Ally X support** to `iio-dsu-bridge`, including support for its BMI323 IMU exposed through Linux IIO.

The bridge reads the accelerometer and gyroscope from the IIO subsystem and exposes them through a local DSU/Cemuhook server.

## Supported Devices

- **ROG Xbox Ally X** - BMI323 combined IMU, tested on SteamOS
- **ROG Ally** - Combined IMU device
- **Legion Go S** - Separate accelerometer and gyroscope IIO devices

The original device support remains available.

## ROG Xbox Ally X

The ROG Xbox Ally X exposes its motion sensors through Linux IIO.

This project reads the BMI323 directly from the Linux IIO subsystem and provides the motion data through the standard DSU/Cemuhook protocol.

### Tested Configuration

- **Device:** ROG Xbox Ally X
- **IMU:** BMI323
- **Gyroscope:** IIO
- **Accelerometer:** IIO
- **Sampling rate:** 200 Hz
- **DSU server:** `127.0.0.1:26760`
- **OS:** SteamOS

## Quick Install (SteamOS Desktop Mode)

The easiest way to install `iio-dsu-bridge` is to use the automatic installer.

### 1. Enter Desktop Mode

Switch your device to **Desktop Mode** and open **Konsole**.

### 2. Run the installer

```bash
bash <(curl -fsSL https://github.com/DreamboxMinerva/iio-dsu-bridge-rog-xbox-ally-x/releases/latest/download/install.sh)
```

### 3. Select your device

The installer will ask which device you have:

```text
1) ROG Ally
2) ROG Xbox Ally X
3) Legion Go S
```

For the **ROG Xbox Ally X**, select:

```text
2
```

The installer will automatically:

1. Download the correct binary
2. Download the device-specific configuration
3. Configure the ROG Xbox Ally X for 200 Hz
4. Create a systemd user service
5. Enable the service
6. Start the service
7. Enable automatic startup
8. Install the uninstaller on the Desktop

When installation is complete, the DSU server will be available at:

```text
127.0.0.1:26760
```

### No terminal needs to remain open

The bridge runs as a background systemd user service.

You can close Konsole after installation.

The bridge will continue running in the background and will automatically start again after reboot.

## Verify the Installation

Check the service:

```bash
systemctl --user status iio-dsu-bridge.service
```

You should see:

```text
Active: active (running)
```

For the ROG Xbox Ally X, the service should use:

```text
--rate=200 --log-every=0
```

### Check the sensor rate

```bash
cat /sys/bus/iio/devices/iio\:device0/in_anglvel_sampling_frequency
```

Expected result:

```text
200.000000
```

## Emulator Setup

The bridge provides a standard DSU/Cemuhook server.

Use:

```text
IP:   127.0.0.1
Port: 26760
```

### Cemu

1. Open **Options → Input Settings**
2. Select your controller
3. Open the **Motion** section
4. Select **DSU Client**
5. Server: `127.0.0.1`
6. Port: `26760`

### Yuzu / Citron

1. Open **Emulation → Configure → Controls**
2. Set the motion provider to **cemuhook / DSU**
3. Server: `127.0.0.1:26760`

### Ryujinx

1. Open **Options → Settings → Input**
2. Select **CemuHook compatible motion server**
3. Server: `127.0.0.1:26760`

### Eden

Configure the motion provider to use **DSU/Cemuhook**.

Server:

```text
127.0.0.1:26760
```

## ROG Xbox Ally X Configuration

The configuration file is:

```text
~/.config/iio-dsu-bridge.yaml
```

The default ROG Xbox Ally X configuration is:

```yaml
mount_matrix:
  x: [1, 0, 0]
  y: [0, -1, 0]
  z: [0, 0, -1]
```

This configuration has been tested with the ROG Xbox Ally X BMI323.

## Performance

The ROG Xbox Ally X configuration uses a **200 Hz sensor rate**.

The default service runs with:

```text
--rate=200 --log-every=0
```

`--log-every=0` disables continuous IMU logging.

The bridge runs as a background process and does not require a terminal window.

## Logs

View the bridge logs with:

```bash
journalctl --user -u iio-dsu-bridge -f
```

Normal startup should show information similar to:

```text
IIO base: /sys/bus/iio/devices/iio:device0
HaveGyro=true
HaveAccel=true
Accel matrix: from config mount_matrix
Gyro matrix: from config mount_matrix
DSU server listening on :26760
```

## Troubleshooting

### Check detected IIO devices

```bash
ls /sys/bus/iio/devices/
```

Then:

```bash
./iio-dsu-bridge --list-iio
```

On the ROG Xbox Ally X, the BMI323 should appear as:

```text
name="bmi323-imu"
gyro=true
accel=true
```

### Check the BMI323 name

```bash
cat /sys/bus/iio/devices/iio\:device0/name
```

Expected:

```text
bmi323-imu
```

### Check the gyro scale

```bash
cat /sys/bus/iio/devices/iio\:device0/in_anglvel_scale
```

The tested ROG Xbox Ally X reports:

```text
0.001065
```

### Check the sampling rate

```bash
cat /sys/bus/iio/devices/iio\:device0/in_anglvel_sampling_frequency
```

Expected:

```text
200.000000
```

### Check the systemd service

```bash
systemctl --user status iio-dsu-bridge.service
```

Restart it with:

```bash
systemctl --user restart iio-dsu-bridge.service
```

### Motion does not work in the emulator

First check that the bridge is running:

```bash
systemctl --user status iio-dsu-bridge.service
```

Then check the logs:

```bash
journalctl --user -u iio-dsu-bridge -n 30
```

Look for:

```text
DSU server listening on :26760
```

Make sure the emulator is configured to use:

```text
127.0.0.1:26760
```

### Motion feels incorrect

The mount matrix controls the sensor orientation.

For the ROG Xbox Ally X:

```yaml
mount_matrix:
  x: [1, 0, 0]
  y: [0, -1, 0]
  z: [0, 0, -1]
```

For debugging:

```bash
./iio-dsu-bridge --debug-raw --debug-dsu --log-every=1
```

Stop the test with `Ctrl+C`.

## Uninstall

The installer places an uninstaller on the Desktop:

`uninstall-iio-dsu-bridge.desktop`

Double-click it to uninstall.

### Manual Uninstall

```bash
systemctl --user disable --now iio-dsu-bridge.service
```

Then:

```bash
rm ~/.config/systemd/user/iio-dsu-bridge.service
rm ~/.local/bin/iio-dsu-bridge
rm ~/.config/iio-dsu-bridge.yaml
```

Finally:

```bash
systemctl --user daemon-reload
```

## Manual Installation

If you do not want to use the automatic installer, you can install the bridge manually.

### 1. Download the binary

```bash
mkdir -p ~/.local/bin

curl -fL \
https://github.com/DreamboxMinerva/iio-dsu-bridge-rog-xbox-ally-x/releases/latest/download/iio-dsu-bridge \
-o ~/.local/bin/iio-dsu-bridge

chmod +x ~/.local/bin/iio-dsu-bridge
```

### 2. Download the ROG Xbox Ally X configuration

```bash
mkdir -p ~/.config

curl -fL \
https://github.com/DreamboxMinerva/iio-dsu-bridge-rog-xbox-ally-x/releases/latest/download/rog-xbox-ally-x.yaml \
-o ~/.config/iio-dsu-bridge.yaml
```

### 3. Create the systemd service

```bash
mkdir -p ~/.config/systemd/user

cat > ~/.config/systemd/user/iio-dsu-bridge.service << 'EOF'
[Unit]
Description=IIO to DSU Bridge for Gyro/Motion Controls (ROG Xbox Ally X)
After=default.target

[Service]
Type=simple
ExecStart=%h/.local/bin/iio-dsu-bridge --rate=200 --log-every=0
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
EOF
```

### 4. Enable and start the service

```bash
systemctl --user daemon-reload
systemctl --user enable --now iio-dsu-bridge.service
```

### 5. Enable automatic startup

Optional:

```bash
sudo loginctl enable-linger $USER
```

## Building From Source

Clone the repository:

```bash
git clone https://github.com/DreamboxMinerva/iio-dsu-bridge-rog-xbox-ally-x.git
cd iio-dsu-bridge-rog-xbox-ally-x
```

Build:

```bash
go build -o iio-dsu-bridge .
```

List detected IIO devices:

```bash
./iio-dsu-bridge --list-iio
```

Run manually:

```bash
./iio-dsu-bridge --rate=200 --log-every=0
```

## Device Configurations

Device-specific configurations are stored in:

```text
examples/
```

Available configurations:

```text
examples/rog-xbox-ally-x.yaml
examples/rog-ally.yaml
examples/legion-go-s.yaml
```

## Command Line Options

| Flag | Default | Description |
| --- | --- | --- |
| `--list-iio` | false | List detected IIO devices and exit |
| `--name` | "" | IIO device name (empty = auto-detect) |
| `--iio-path` | "" | Explicit IIO device path (overrides `--name`) |
| `--addr` | `127.0.0.1:26760` | DSU server address |
| `--rate` | 250 | Output rate in Hz |
| `--log-every` | 25 | Print IMU data every N samples (`0` = off) |
| `--set-scales` | true | Auto-set sensor scales if zero |
| `--set-rate` | true | Auto-set sampling frequency |
| `--debug-raw` | false | Show raw sensor values before transformation |
| `--debug-dsu` | false | Show final DSU packet values |

## Development

Pull requests and testing reports are welcome, especially regarding:

- Different SteamOS versions
- Other ROG Xbox Ally X revisions
- Other emulators
- Sensor filtering
- Sampling rates
- Motion orientation
- Battery and performance impact

## Credits

This project is based on:

**Sebalvarez97 / iio-dsu-bridge**

https://github.com/Sebalvarez97/iio-dsu-bridge

Special thanks to:

- **Sebalvarez97** - Original IIO → DSU bridge
- **Tobi Demeco** - Legion Go S support, configurations and improvements
- **Christopher Lott** - Legion Go S support

## License

See the original project's license.

Please preserve the original project's copyright notices, license and attribution requirements when modifying or redistributing this project.
