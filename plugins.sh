#!/bin/bash

# Function to fetch and download the latest plugin version for a project and loader(s)
fetch_latest_version() {
    local project_slug=$1
    shift
    local loaders=("$@")
    
    # Modrinth API URL
    local api_url="https://api.modrinth.com/v2/project/${project_slug}/version"
    
    # Ensure the necessary directories exist
    mkdir -p plugins
    mkdir -p plugins/Geyser-Spigot/extensions

    # Fetch versions data and filter by loaders
    local latest_version_data=$(curl -s "${api_url}" | jq -r --argjson loaders "$(printf '%s\n' "${loaders[@]}" | jq -R . | jq -s .)" '
        map(select(.loaders[] as $l | $loaders | index($l))) |
        sort_by(.date_published) | last')

    # Extract the download URL
    local download_url=$(echo "$latest_version_data" | jq -r '.files[0].url // empty')

    # Download the plugin if the URL is available
    if [[ -n "$download_url" ]]; then
        echo "Downloading $project_slug..."
        wget -q -O "plugins/${project_slug}.jar" "$download_url" && \
        echo "Saved to plugins/${project_slug}.jar" || \
        echo "Failed to download $project_slug."
    else
        echo "No compatible versions found for $project_slug with loaders: ${loaders[*]}."
    fi
}

# Function to download the latest JAR file from a GitHub release using API
fetch_latest_github() {
    local repo_url="$1"
    local filename="$2"
    local download_url=$(curl -s "$repo_url/releases/latest" | grep -o '"browser_download_url": "[^"]*' | grep -o 'https://.*\.jar')
    
    if [ -z "$download_url" ]; then
        echo "No JAR file found on GitHub releases page for $filename."
        return 1
    fi
    
    wget "$download_url" -O "plugins/$filename.jar"
    echo "Saved to $filename.jar"
}

fetch_latest_geyser_github() {
    local repo_url="$1"
    local filename="$2"
    local download_url=$(curl -s "$repo_url/releases/latest" | grep -o '"browser_download_url": "[^"]*' | grep -o 'https://.*\.jar')
    
    if [ -z "$download_url" ]; then
        echo "No JAR file found on GitHub releases page for $filename."
        return 1
    fi
    
    wget "$download_url" -O "plugins/Geyser-Spigot/extensions/$filename.jar"
    echo "Saved to $filename.jar"
}

# Example usage with multiple projects and loaders
projects=("simple-voice-chat" "worldedit" "chunky" "bluemap" "luckperms" "packstacker" "knockbacksync" "packetevents" "geyser-recipe-fix" "geyserextras" "interactionvisualizer" "holomobhealth")
loaders=("paper" "paper" "paper" "paper" "paper" "paper" "paper" "paper" "paper" "paper" "paper" "paper" "paper")

# Delete all plugins to download fresh ones
rm -f plugins/Geyser-Spigot/extensions/*.jar
rm -f plugins/*.jar

# Download latest plugins
for project in "${projects[@]}"; do
    fetch_latest_version "$project" "${loaders[@]}"
done

wget https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot -O plugins/geyser.jar
wget https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/spigot -O plugins/floodgate.jar
wget https://download.geysermc.org/v2/projects/thirdpartycosmetics/versions/latest/builds/latest/downloads/thirdpartycosmetics -O plugins/Geyser-Spigot/extensions/thirdpartycosmetics.jar
wget https://github.com/dmulloy2/ProtocolLib/releases/latest/download/ProtocolLib.jar -O plugins/protocollib.jar
wget https://github.com/MilkBowl/Vault/releases/latest/download/Vault.jar -O plugins/vault.jar

fetch_latest_github "https://api.github.com/repos/Ivan8or/GoldenDupes" "goldendupes" || true
fetch_latest_github "https://api.github.com/repos/ViaVersion/ViaVersion" "viaversion" || true
fetch_latest_github "https://api.github.com/repos/ViaVersion/ViaBackwards" "viabackwards" || true
fetch_latest_github "https://api.github.com/repos/ViaVersion/ViaRewind" "viarewind" || true
fetch_latest_github "https://api.github.com/repos/2008Choco/VeinMiner" "veinminer" || true

fetch_latest_geyser_github "https://api.github.com/repos/onebeastchris/LuckLink" "lucklink" || true
fetch_latest_geyser_github "https://api.github.com/repos/Carbuino/EmoteMenu" "emotemenu" || true
fetch_latest_geyser_github "https://api.github.com/repos/onebeastchris/PickPack" "pickpack" || true
