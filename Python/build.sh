#!/usr/bin/env bash
# exit on error
set -o errexit

# Upgrade pip
pip install --upgrade pip

# Install build tools INCLUDING ninja
apt-get update && apt-get install -y build-essential ninja-build

# Install Python dependencies
pip install -r requirements.txt
