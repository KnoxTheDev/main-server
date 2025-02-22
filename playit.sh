#!/usr/bin/env bash
set -e  # Exit on any error

# Check if PLAYIT_SECRET is set
if [[ -z "$PLAYIT_SECRET" ]]; then
    echo "Error: PLAYIT_SECRET is not set. Make sure it's defined in HF Spaces secrets."
    exit 1
fi

# Remove existing binary if it exists
if [[ -f "playit-linux-amd64" ]]; then
    echo "Removing old playit binary..."
    rm playit-linux-amd64
fi

# Download the latest Playit binary
echo "Downloading Playit agent..."
wget -q --show-progress https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64 || {
    echo "Download failed!"
    exit 1
}

# Make it executable
chmod +x playit-linux-amd64

# Run the Playit agent with the secret key
echo "Starting Playit agent..."
exec ./playit-linux-amd64 --platform_docker --secret "$PLAYIT_SECRET"
