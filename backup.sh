#!/bin/bash

# Define world folder names
OVERWORLD="Knoxius SMP"
NETHER="Knoxius SMP_nether"
END="Knoxius SMP_the_end"

# Define Hugging Face credentials
HF_USERNAME="knoxius"
HF_DATASET="primary"

# Hugging Face repository URL with authentication
HF_ORIGIN="https://${HF_USERNAME}:${HF_TOKEN}@huggingface.co/datasets/${HF_USERNAME}/${HF_DATASET}.git"

# Archive the worlds into worlds.zip
zip -r worlds.zip "$OVERWORLD" "$NETHER" "$END"

# Clone or update the Hugging Face dataset repo
if [ ! -d "backup-repo/.git" ]; then
    git clone "$HF_ORIGIN" backup-repo
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
git config --global pull.rebase true

# Enable LFS for worlds.zip
git lfs install
git lfs track "worlds.zip"

# Ensure .gitattributes is added
git add .gitattributes

# Add and commit the backup
git add worlds.zip
git commit -m "Automated backup: $(date '+%Y-%m-%d %H:%M:%S')" || echo "No changes to commit."

# Push to Hugging Face with LFS
git push origin main
