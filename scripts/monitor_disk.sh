#!/bin/bash

###############################################################################
# Monitor Disk Usage
#
# This script monitors the disk usage of a specified disk and sends a request
# to a specified URL based on the disk usage percentage.
#
# Usage:    ./monitor_disk.sh --disk DISK --limit LIMIT --push-url URL
# Example:  ./monitor_disk.sh --disk '/dev/mapper/ubuntu--vg-ubuntu--lv' --limit '75' --push-url 'https://example.com/api/push/TOKEN'
#
# Add cron job to run this script every 5 minutes:
# */5 * * * * /path/to/monitor_disk.sh --disk /dev/sda1 --limit 80 --push-url http://example.com
#
###############################################################################

set -e  # Exit immediately if a command exits with a non-zero status

is_integer() {
    [[ "$1" =~ ^-?[0-9]+$ ]]
}

show_help() {
    echo "Usage: $0 --disk DISK --limit LIMIT --push-url URL"
    echo
    echo "Options:"
    echo "  --disk DISK       The disk to monitor (e.g., /dev/sda1)"
    echo "  --limit LIMIT     The disk usage percentage limit (e.g., 80)"
    echo "  --push-url URL    The URL to send the request to"
    echo "  --help            Display this help message"
    exit 0
}

# Function to format the URL
format_url() {
    local status=$1
    local msg=$2
    local url="${PUSH_URL}?status=${status}&msg=${msg}"
    echo "${url// /%20}"  # Replace spaces with %20
}


# Parse command-line options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --disk) DISK="$2"; shift ;;
        --limit) LIMIT="$2"; shift ;;
        --push-url) PUSH_URL="$2"; shift ;;
        --help) show_help ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Check if DISK and LIMIT are set
if [ -z "$DISK" ] || [ -z "$LIMIT" ]; then
    echo "Usage: $0 --disk <disk_path> --limit <limit_value> --push-url <url>"
    exit 1
fi

PERCENTAGE=$(df -hl --total "${DISK}" | tail -1 | awk '{printf $5}')  # Get disk usage percentage
NUMBER=${PERCENTAGE%\%*}  # Remove the percentage sign

# Check if NUMBER is an integer
if ! is_integer "$NUMBER"; then
    echo "Error: Disk usage percentage is not an integer."
    exit 1
fi

# Determine the status based on the disk usage percentage
if [ "$NUMBER" -lt "$LIMIT" ]; then
    URL=$(format_url "up" "$NUMBER")
else
    URL=$(format_url "down" "$NUMBER")
fi

curl --fail --no-progress-meter --retry 3 "$URL" # Send the request to the formatted URL
