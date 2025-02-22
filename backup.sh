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

# Clone or update the repository
if [ ! -d "backup-repo/.git" ]; then
    git clone "$ORIGIN" backup-repo
else
    cd backup-repo || exit 1
    git pull origin main
    cd ..
fi

# Move the backup to the repo folder
mv worlds.zip backup-repo/

# Navigate to the repo directory
cd backup-repo || exit 1

# Configure Git
git config --global user.email "backup-bot@server.com"
git config --global user.name "Backup Bot"

# Add and commit the backup
git add worlds.zip
git commit -m "Automated backup: $(date '+%Y-%m-%d %H:%M:%S')" || echo "No changes to commit."

# Push to the repository
git push origin main
