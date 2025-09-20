#!/usr/bin/env bash
# exit on error
set -o errexit

# Upgrade pip and ALL core packaging tools first
pip install --upgrade pip setuptools wheel

# Now, install the project requirements
pip install -r requirements.txt
