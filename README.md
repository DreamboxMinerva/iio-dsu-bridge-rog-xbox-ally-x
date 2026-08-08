# iio-dsu-bridge

IIO → DSU (Cemuhook) motion bridge for Linux handhelds.

This fork adds **ROG Xbox Ally X support** to `iio-dsu-bridge`, including support for its BMI323 IMU exposed through Linux IIO.

The bridge reads the accelerometer and gyroscope from the IIO subsystem and exposes them through a local DSU/Cemuhook server.

## Supported Devices

- **ROG Xbox Ally X** - BMI323 combined IMU, tested on SteamOS
- **ROG Ally** - Combined IMU device
- **Legion Go S** - Separate accelerometer and gyroscope IIO devices

The original device support remains available.

---

## ROG Xbox Ally X

The ROG Xbox Ally X exposes its motion sensors through Linux IIO instead of the HID interface used by Steam Deck gyro solutions.

This project reads the BMI323 directly from:

```text
/sys/bus/iio/devices/iio:deviceX
