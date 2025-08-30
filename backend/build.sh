#!/bin/bash
# Force Python 3.11 and install dependencies

echo "Setting up Python 3.11 environment..."

# Install Python 3.11 if not available
if ! command -v python3.11 &> /dev/null; then
    echo "Installing Python 3.11..."
    apt-get update && apt-get install -y python3.11 python3.11-venv python3.11-dev
fi

# Create virtual environment with Python 3.11
python3.11 -m venv .venv
source .venv/bin/activate

# Upgrade pip
pip install --upgrade pip

# Install requirements
pip install -r requirements.txt

echo "Build completed successfully!"
