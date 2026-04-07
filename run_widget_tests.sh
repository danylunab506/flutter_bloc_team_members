#!/bin/bash
set -e

echo "Running widget tests..."
flutter test test/widget_testing --reporter expanded

echo "Done."
