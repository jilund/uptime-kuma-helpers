# Uptime Kuma Helper Scripts

## Disk Monitor

This script monitors the disk usage of a specified disk and sends a request to a specified URL based on the disk usage percentage.

The script uses this to get filesystem and mount details. <br/>
You can get your filesystem mount path from there.

```sh
df -hl --total
```

### Usage

```sh
./monitor_disk.sh --disk DISK --limit LIMIT --push-url URL
```

###r Example

```sh
./monitor_disk.sh --disk '/dev/mapper/ubuntu--vg-ubuntu--lv' \
    --limit '75' \
    --push-url 'https://example.com/api/push/TOKEN'
```
