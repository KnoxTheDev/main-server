#!/bin/bash

# Retrieve the secret from Hugging Face Spaces environment variables
SECRET_KEY="${PLAYIT_SECRET}"

# Check if the playit binary exists and remove it if it does
if [ -f "playit-linux-amd64" ]; then
    rm playit-linux-amd64
fi

# Download the latest playit binary
wget -q https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64

# Make it executable
chmod +x playit-linux-amd64

# Run the Playit agent with the secret key
./playit-linux-amd64 --platform_linux --secret "$SECRET_KEY"
