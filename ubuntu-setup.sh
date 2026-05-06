#!/bin/bash

LOG_FILE="log/ubuntu-setup.log"

log() {
    echo "$1" | tee -a "$LOG_FILE"
}

init() {
    log "Initializing setup.."
    echo -n "Please paste in your public key: "
    read -r PUBLIC_KEY
    if [ -n "$PUBLIC_KEY" ]; then
        log "  - Public key received"
    else
        log "  - No public key provided, skipping SSH key setup"
    fi
}

install_dev() {
    log "Setting up development environment.."
    log "  - Installing build tools"
    log "  - Installing Git"
    log "  - Installing Python"
    log "  - Installing Node.js"
    log "  - Installing Docker"
    log "  - Installing VS Code"
}

install_web() {
    log "Setting up web server.."
    log "  - Installing Apache/Nginx"
    log "  - Installing PHP"
    log "  - Installing MySQL/MariaDB"
    log "  - Configuring firewall"
}

install_media() {
    log "Setting up media tools.."
    log "  - Installing FFmpeg"
    log "  - Installing GIMP"
    log "  - Installing Blender"
    log "  - Installing Audacity"
}

install_apps() {
    log "Setting up applications.."
    log "  - Installing Slack"
    log "  - Installing Discord"
    log "  - Installing Chrome"
    log "  - Installing Spotify"
}

init

log "Setting up Ubuntu.."

MODE="all"

while getopts "i:" opt; do
    case $opt in
        i)
            MODE="$OPTARG"
            ;;
        *)
            echo "Usage: $0 -i [dev|web|media|apps|all(default)]" >&2
            exit 1
            ;;
    esac
done

case "$MODE" in
    dev)
        install_dev
        ;;
    web)
        install_web
        ;;
    media)
        install_media
        ;;
    apps)
        install_apps
        ;;
    all)
        install_dev
        install_web
        install_media
        install_apps
        ;;
    *)
        echo "Invalid option: $MODE" >&2
        exit 1
        ;;
esac

log "Setup complete"