#!/usr/bin/env bash
# exit on error
set -o errexit

# Install Flutter
git clone https://github.com/flutter/flutter.git
export PATH="$PATH:`pwd`/flutter/bin"

# Run your app's build command
flutter build web