#!/bin/bash

# Define world folder names
OVERWORLD="Knoxius SMP"
NETHER="Knoxius SMP_nether"
END="Knoxius SMP_the_end"

# Define Hugging Face dataset repository
HF_DATASET_REPO="https://knoxius:${HF_TOKEN}@huggingface.co/datasets/knoxius/primary"

# Archive the worlds into worlds.zip
zip -r worlds.zip "$OVERWORLD" "$NETHER" "$END"

# Clone or update the dataset repository
if [ ! -d "backup-repo/.git" ]; then
    git clone "$HF_DATASET_REPO" backup-repo
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
git config --global pull.rebase true  # Enable rebase for git pull

# Add and commit the backup
git add worlds.zip
git commit -m "Automated backup: $(date '+%Y-%m-%d %H:%M:%S')" || echo "No changes to commit."

# Push to the Hugging Face dataset repository
git push origin main
