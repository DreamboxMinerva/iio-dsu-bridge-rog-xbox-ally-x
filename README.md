# iio-dsu-bridge

IIO → DSU (Cemuhook) motion bridge for Linux handhelds.

This fork adds **ROG Xbox Ally X** support, including automatic startup on SteamOS and a device-specific configuration for its BMI323 IMU.

Based on the original project by [Sebalvarez97](https://github.com/Sebalvarez97/iio-dsu-bridge).

## Supported Devices

- **ROG Xbox Ally X** - BMI323 combined IMU, tested on SteamOS
- **ROG Ally** - Combined IMU device
- **Legion Go S** - Separate accelerometer and gyroscope IIO devices

## ROG Xbox Ally X

The ROG Xbox Ally X exposes its BMI323 IMU through Linux IIO.

Detected device:

```text
/sys/bus/iio/devices/iio:device0
name="bmi323-imu"
gyro=true
accel=true

Tested sensor values:

Gyroscope scale:     0.001065
Accelerometer scale: 0.002394
Sampling frequency:  200 Hz

The following configuration has been tested successfully on SteamOS:

mount_matrix:
  x: [1, 0, 0]
  y: [0, -1, 0]
  z: [0, 0, -1]
Tested
SteamOS
Eden
The Legend of Zelda: Tears of the Kingdom
Cemu
DSU server: 127.0.0.1:26760
Automatic startup through systemd
Gyro remains functional after reboot
Quick Install
SteamOS Desktop Mode

Download the installer from the latest Release and run it from Desktop Mode.

The installer will:

Detect or ask for the device.
Download the iio-dsu-bridge binary.
Install the device-specific configuration.
Create a user-level systemd service.
Configure the ROG Xbox Ally X for 200 Hz.
Start the DSU server automatically.

After installation, compatible emulators can connect to:

127.0.0.1:26760

No terminal window needs to remain open.

Manual Installation
1. Download the binary
mkdir -p ~/.local/bin

curl -fL \
  https://github.com/DreamboxMinerva/iio-dsu-bridge-rog-xbox-ally-x/releases/latest/download/iio-dsu-bridge \
  -o ~/.local/bin/iio-dsu-bridge

chmod +x ~/.local/bin/iio-dsu-bridge
2. Install the configuration
mkdir -p ~/.config
ROG Xbox Ally X
curl -fL \
  https://github.com/DreamboxMinerva/iio-dsu-bridge-rog-xbox-ally-x/releases/latest/download/rog-xbox-ally-x.yaml \
  -o ~/.config/iio-dsu-bridge.yaml
ROG Ally
curl -fL \
  https://github.com/DreamboxMinerva/iio-dsu-bridge-rog-xbox-ally-x/releases/latest/download/rog-ally.yaml \
  -o ~/.config/iio-dsu-bridge.yaml
Legion Go S
curl -fL \
  https://github.com/DreamboxMinerva/iio-dsu-bridge-rog-xbox-ally-x/releases/latest/download/legion-go-s.yaml \
  -o ~/.config/iio-dsu-bridge.yaml
3. Create the systemd service
mkdir -p ~/.config/systemd/user

cat > ~/.config/systemd/user/iio-dsu-bridge.service << 'EOF'
[Unit]
Description=IIO to DSU Bridge for Gyro/Motion Controls
After=default.target

[Service]
Type=simple
ExecStart=%h/.local/bin/iio-dsu-bridge --rate=200 --log-every=0
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
EOF
4. Enable and start
systemctl --user daemon-reload
systemctl --user enable --now iio-dsu-bridge.service

Check the service:

systemctl --user status iio-dsu-bridge.service
5. Optional: start automatically after login
sudo loginctl enable-linger $USER
Emulator Setup
Eden

Configure the motion/gyro source as a DSU/Cemuhook server:

Server: 127.0.0.1
Port:   26760

Use Eden's motion test to verify the gyro.

Cemu
Open Options → Input Settings.
Select the controller.
Open the Motion section.
Set the motion source to DSU Client.

Server:

127.0.0.1

Port:

26760
Yuzu / Citron
Open Emulation → Configure → Controls.
Set the motion provider to cemuhook/DSU.

Use:

127.0.0.1:26760
Ryujinx
Open Options → Settings → Input.
Select the CemuHook-compatible motion server.

Use:

127.0.0.1:26760
Configuration

The configuration file is:

~/.config/iio-dsu-bridge.yaml
ROG Xbox Ally X
mount_matrix:
  x: [1, 0, 0]
  y: [0, -1, 0]
  z: [0, 0, -1]
ROG Ally
mount_matrix:
  x: [1, 0, 0]
  y: [0, -1, 0]
  z: [0, 0, -1]
Legion Go S
accel_matrix:
  x: [1, 0, 0]
  y: [0, 1, 0]
  z: [0, 0, -1]

gyro_matrix:
  x: [1, 0, 0]
  y: [0, 0, 1]
  z: [0, 1, 0]
ROG Xbox Ally X Recommended Settings

The ROG Xbox Ally X BMI323 was tested at:

200 Hz

The recommended service configuration is:

./iio-dsu-bridge --rate=200 --log-every=0

--log-every=0 disables continuous IMU logging during normal operation.

Debug logging should only be enabled when troubleshooting.

Command Line Options
Flag	Default	Description
--list-iio	false	List detected IIO devices and exit
--name	""	IIO device name
--iio-path	""	Explicit IIO device path
--addr	127.0.0.1:26760	DSU server address
--rate	250	Output rate in Hz
--log-every	25	Print IMU data every N samples; 0 disables logging
--set-scales	true	Automatically set sensor scales if required
--set-rate	true	Try to configure the sensor sampling frequency
--debug-raw	false	Show raw sensor values
--debug-dsu	false	Show final DSU packet values
Troubleshooting
Check IIO devices
ls -la /sys/bus/iio/devices/
Check the IMU
cat /sys/bus/iio/devices/iio:device0/name

The ROG Xbox Ally X should report:

bmi323-imu
List detected IIO devices
./iio-dsu-bridge --list-iio

Expected:

/sys/bus/iio/devices/iio:device0
name="bmi323-imu"
gyro=true
accel=true
Check the gyro scale
cat /sys/bus/iio/devices/iio:device0/in_anglvel_scale

Expected on the tested ROG Xbox Ally X:

0.001065
Check the sampling frequency
cat /sys/bus/iio/devices/iio:device0/in_anglvel_sampling_frequency

Expected:

200.000000
Test the gyro manually
./iio-dsu-bridge --debug-raw --log-every=1

Move the handheld and verify that the gyro values change.

Stop it with:

Ctrl+C
Motion feels wrong

The mount matrix may need adjustment.

Use:

./iio-dsu-bridge --debug-raw --debug-dsu --log-every=1

to inspect raw and transformed values.

No config file error

If you see:

ERROR: No mount matrix configured.

create:

~/.config/iio-dsu-bridge.yaml

For the ROG Xbox Ally X:

mount_matrix:
  x: [1, 0, 0]
  y: [0, -1, 0]
  z: [0, 0, -1]
Check the systemd service
systemctl --user status iio-dsu-bridge.service

View logs:

journalctl --user -u iio-dsu-bridge -f

Restart the service:

systemctl --user restart iio-dsu-bridge.service
Uninstall
Stop and disable the service
systemctl --user disable --now iio-dsu-bridge.service
Remove the service
rm ~/.config/systemd/user/iio-dsu-bridge.service
Remove the binary
rm ~/.local/bin/iio-dsu-bridge
Remove the configuration
rm ~/.config/iio-dsu-bridge.yaml
Reload systemd
systemctl --user daemon-reload
Building from Source

Clone this fork:

git clone https://github.com/DreamboxMinerva/iio-dsu-bridge-rog-xbox-ally-x.git
cd iio-dsu-bridge-rog-xbox-ally-x

Build:

go build -o iio-dsu-bridge .

Run:

./iio-dsu-bridge --rate=200 --log-every=0
Development

Device-specific configurations are stored in:

examples/

Current configurations:

examples/rog-xbox-ally-x.yaml
examples/rog-ally.yaml
examples/legion-go-s.yaml

The ROG Xbox Ally X configuration was tested using the BMI323 IMU exposed through Linux IIO on SteamOS.

Credits

This project is based on:

Sebalvarez97 / iio-dsu-bridge

https://github.com/Sebalvarez97/iio-dsu-bridge

Special thanks to:

Sebalvarez97 - original IIO → DSU bridge
Tobi Demeco - Legion Go S support, configurations and improvements
Christopher Lott - Legion Go S support
License

See the original project's license.

Please preserve the original project's copyright notices, license and attribution requirements when modifying or redistributing this project.
