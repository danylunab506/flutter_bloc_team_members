#!/bin/bash
set -e

DEVICE=$(flutter devices | grep -v "^$" | grep -v "^No devices" | awk 'NR==2 {print $1}')

if [ -z "$DEVICE" ]; then
  echo "No devices available. Start a simulator and try again."
  exit 1
fi

echo "Running on device: $DEVICE"
flutter run -d "$DEVICE"
