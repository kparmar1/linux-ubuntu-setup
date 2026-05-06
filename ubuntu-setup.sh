#!/bin/bash

TIMESTAMP=$(date +"%d-%m-%Y--%H-%M-%S")
LOG_FILE="log/ubuntu-setup-${TIMESTAMP}.log"

# Redirect both stdout and stderr to tee
exec > >(tee -a "$LOG_FILE") 2>&1

declare -A SETUP_OPTIONS=(
    ["dev"]="install_dev"
    ["web"]="install_web"
    ["media"]="install_media"
    ["apps"]="install_apps"
    ["secure"]="install_secure"
)

init() {
    echo "Initializing setup.."
    echo -n "Please paste in your public key: "
    read -r PUBLIC_KEY
    if [ -n "$PUBLIC_KEY" ]; then
        echo "  - Public key received"
    else
        echo "  - No public key provided, skipping SSH key setup"
    fi
}

install_dev() {
    echo "Setting up development environment.."
    echo "  - Installing build tools"
    echo "  - Installing Git"
    echo "  - Installing Python"
    echo "  - Installing Node.js"
    echo "  - Installing Docker"
    echo "  - Installing VS Code"
}

install_web() {
    echo "Setting up web server.."
    echo "  - Installing Apache/Nginx"
    echo "  - Installing PHP"
    echo "  - Installing MySQL/MariaDB"
    echo "  - Configuring firewall"
}

install_media() {
    echo "Setting up media tools.."
    echo "  - Installing FFmpeg"
    echo "  - Installing GIMP"
    echo "  - Installing Blender"
    echo "  - Installing Audacity"
}

install_apps() {
    echo "Setting up applications.."
    echo "  - Installing Slack"
    echo "  - Installing Discord"
    echo "  - Installing Chrome"
    echo "  - Installing Spotify"
}

install_secure () {
    echo "Securing the os.."

    # stop all telemtry
    echo "   Stopping all telemetry.."
    ubuntu-report -f send no
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

echo "Setting up Ubuntu.."

if [ "$MODE" = "all" ]; then
    for option in "${!SETUP_OPTIONS[@]}"; do
        "${SETUP_OPTIONS[$option]}"
    done
else
    "${SETUP_OPTIONS[$MODE]}"
fi

echo "Setup complete"