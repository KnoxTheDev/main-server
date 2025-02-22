#!/bin/bash

# Define world folder names
OVERWORLD="Knoxius SMP"
NETHER="Knoxius SMP_nether"
END="Knoxius SMP_the_end"

# Define GitHub credentials
GITHUB_USERNAME="KnoxTheDev"
GITHUB_REPO="main-server"

# Define GitHub repository URL using the token
ORIGIN="https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/${GITHUB_USERNAME}/${GITHUB_REPO}.git"

# Archive the worlds into worlds.zip
zip -r worlds.zip "$OVERWORLD" "$NETHER" "$END"

# Configure Git
git config --global user.email "backup-bot@server.com"
git config --global user.name "Backup Bot"

# Initialize repo if not already
git init
git remote add origin "$ORIGIN" 2>/dev/null || git remote set-url origin "$ORIGIN"

# Add and commit the backup
git add worlds.zip
git commit -m "Automated backup: $(date '+%Y-%m-%d %H:%M:%S')"

# Push to the repository
git branch -M main
git push -u origin main
