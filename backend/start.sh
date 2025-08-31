#!/bin/bash
# Start script that forces Python 3.11

echo "Starting with Python 3.11..."

# Check if Python 3.11 is available
if command -v python3.11 &> /dev/null; then
    echo "Using Python 3.11"
    python3.11 -m gunicorn run:app --bind 0.0.0.0:$PORT
else
    echo "Python 3.11 not found, falling back to default"
    gunicorn run:app --bind 0.0.0.0:$PORT
fi
