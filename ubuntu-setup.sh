#!/bin/bash

TIMESTAMP=$(date +"%d-%m-%Y--%H-%M-%S")
LOG_FILE="log/ubuntu-setup-${TIMESTAMP}.log"

log() {
    echo "$1" | tee -a "$LOG_FILE"
}

declare -A SETUP_OPTIONS=(
    ["dev"]="install_dev"
    ["web"]="install_web"
    ["media"]="install_media"
    ["apps"]="install_apps"
)

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

clean_logs() {
    rm -f log/*.log
    echo "Log files cleaned"
}

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo "  -c    Clean log directory"
    echo -n "  -i    Setup option: "
    printf "%s " "${!SETUP_OPTIONS[@]}" | sed 's/ /|/g'
    echo "(default: all)"
    echo "  -h    Show this help message"
}

MODE="all"
CLEAN=0

while getopts "ci:h" opt; do
    case $opt in
        c)
            CLEAN=1
            ;;
        h)
            show_help
            exit 0
            ;;
        i)
            MODE="$OPTARG"
            ;;
        *)
            echo "Invalid option: $MODE" >&2
            show_help >&2
            exit 1
            ;;
    esac
done

if [ "$CLEAN" -eq 1 ]; then
    clean_logs
    exit 0
fi

if [ "$MODE" != "all" ] && [ -z "${SETUP_OPTIONS[$MODE]}" ]; then
    show_help >&2
    exit 1
fi

init

log "Setting up Ubuntu.."

if [ "$MODE" = "all" ]; then
    for option in "${!SETUP_OPTIONS[@]}"; do
        "${SETUP_OPTIONS[$option]}"
    done
else
    "${SETUP_OPTIONS[$MODE]}"
fi

log "Setup complete"