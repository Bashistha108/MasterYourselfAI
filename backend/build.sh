#!/bin/bash
# Force Python 3.11 installation and setup

echo "Setting up Python 3.11 environment..."

# Install Python 3.11
apt-get update
apt-get install -y python3.11 python3.11-venv python3.11-dev

# Create virtual environment with Python 3.11
python3.11 -m venv .venv
source .venv/bin/activate

# Upgrade pip
python3.11 -m pip install --upgrade pip

# Install requirements
python3.11 -m pip install -r backend/requirements.txt

echo "Build completed successfully!"
