# Comgy Exporter

Prometheus exporter, that fetches the device information
for shelly devices

## State of Project

Experimental / in development


## Usage

With docker compose:

```yml
services:
  shelly-cloud-exporter:
    build: "."
    restart: always
    ports:
      - 9112:9112
    environment:
      AUTHORIZATION_KEY: <token>
      SERVER_URL: https://shelly-12-eu.shelly.cloud/
      DEVICE_IDS: 123123123,123123123
```

## Example metric output

```
# HELP shelly_cloud_device Current Power
# TYPE shelly_cloud_device gauge
"shelly_cloud_device{device_id="3ce90ed7f7e4"} 4.54"

# HELP shelly_cloud_device Current Wifi rssi
# TYPE shelly_cloud_device gauge
"shelly_cloud_device{device_id="3ce90ed7f7e4"} -76"
```
