#!/bin/bash

TIMESTAMP=$(date +"%d-%m-%Y--%H-%M-%S")
LOG_DIR=log
LOG_FILE="${LOG_DIR}/ubuntu-setup-${TIMESTAMP}.log"
KEY_FILES="keys"
BACKGROUND_IMAGE=linux-desktop.jpg
BACKGROUND_IMAGE_TARGET=~/Pictures/background
BACKGROUND_IMAGE_SOURCE=images/${BACKGROUND_IMAGE}

declare -A SETUP_OPTIONS=(
    ["init"]="init"
    ["secure"]="install_secure"
    ["dev"]="install_dev"
    ["media"]="install_media"
    ["apps"]="install_apps"
    ["shell"]="install_shell"
    ["xfce"]="install_xfce"
    ["display-settings"]="install_display_settings"
)

SETUP_ORDER=(init secure dev media apps shell xfce display-settings)


init() {
    echo "Initializing setup.."

    echo "  - Updating OS"
    sudo apt-get update -y
    sudo apt-get upgrade -y

    echo "  - Removing Snap & Block"
    snap list | grep -v base | awk '{print $1}' | grep -v Name | grep -v snapd | xargs -I{} sudo snap remove {} --purge
    snap list | grep base | awk '{print $1}' | grep -v Name | xargs -I{} sudo snap remove {} --purge
    sudo systemctl disable --now snapd.socket snapd.service
    sudo apt-get remove --purge -y snapd
    sudo rm -rf /var/cache/snapd ~/snap /snap /var/snap
    sudo tee /etc/apt/preferences.d/no-snap.pref <<EOF
    Package: snapd
    Pin: release a=*
    Pin-Priority: -10
EOF
    sudo apt-get autoremove

    echo "  - Installing Flatpak"
    sudo apt-get install flatpak -y

    echo "  - Ubuntu Restricted Extras"
    echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections
    sudo apt-get install ubuntu-restricted-extras -y

    sudo install -m 0755 -d /etc/apt/keyrings
}

install_secure () {
    declare -A TELEMETRY_SITES=(
    ["www.metrics.ubuntu.com"]="127.0.0.1"
    ["metrics.ubuntu.com"]="127.0.0.1"
    ["www.popcon.ubuntu.com"]="127.0.0.1"
    ["popcon.ubuntu.com"]="127.0.0.1"
    )

    echo "Securing the Linux OS.."
    echo
    echo

    # stop all telemtry
    echo "  - Stopping all telemetry.."
    if command -v ubuntu-report &>/dev/null; then
        ubuntu-report -f send no
    fi

    for site in "${!TELEMETRY_SITES[@]}"; do
        if ! grep -Fq " ${site}" "/etc/hosts"; then
            echo "${TELEMETRY_SITES[$site]} $site" | sudo tee -a /etc/hosts
        fi
    done

    sudo apt-get purge -y ubuntu-report popularity-contest apport whoopsie apport-symptoms
    sudo apt-mark hold ubuntu-report popularity-contest apport whoopsie apport-symptoms
    sudo apt-get autoremove -y


    echo "  - Enable UFW (firewall).."
    sudo ufw enable
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

install_packages_internal() {
    for package in "$@"; do
        echo "  - Installing package ${package}"
        sudo apt-get install "${package}" -y
    done
}

install_dev() {
    PACKAGES="net-tools
    btop
    fastfetch
    git subversion
    util-linux-extra
    finger
    keepassxc
    curl
    openjdk-21-jdk
    openjdk-25-jdk
    apt-file
    timeshift
    gawk
    kitty
    flameshot
    vim"
    install_packages_internal ${PACKAGES}
    install_dev_complex
}

install_dev_complex() {
    echo "  - Copying keys (if found)"
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    cp -p ${KEY_FILES}/* ~/.ssh/ 2>/dev/null || true

    echo "  - Installing Docker"
    sudo apt-get remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1)
    sudo apt-get update
    sudo apt-get install ca-certificates curl -y
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
    sudo apt-get update -y
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    getent group docker || sudo groupadd docker
    sudo usermod -aG docker $USER
    newgrp docker


    echo "  - Installing VS Code"
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo install -D -o root -g root -m 644 /dev/stdin /etc/apt/keyrings/packages.microsoft.gpg
    echo "deb [arch=amd64,arm64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
    sudo apt-get update -y
    sudo apt-get install code -y
}

install_media() {
    echo "Setting up media tools.."
    PACKAGES="ffmpeg
    gimp
    audacity
    vlc"
    install_packages_internal ${PACKAGES}
}

install_apps() {
    echo "Setting up other applications.."
    PACKAGES=""
    install_packages_internal ${PACKAGES}
    install_apps_complex
}

install_apps_complex() {
    echo "  - Installing Firefox"
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
    echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee /etc/apt/sources.list.d/mozilla.list
    sudo tee /etc/apt/preferences.d/mozilla << 'EOF'
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
EOF
    sudo apt-get update
    sudo apt-get install firefox


    echo "  - Installing Brave"
    curl -fsS https://dl.brave.com/install.sh | sh

    echo "  - Installing Thunderbird"
    sudo add-apt-repository ppa:mozillateam/ppa -y
    printf '%s\n' 'Package: thunderbird*' 'Pin: release o=LP-PPA-mozillateam' 'Pin-Priority: 1001' '' 'Package: thunderbird*' 'Pin: release o=Ubuntu' 'Pin-Priority: -1' | sudo tee /etc/apt/preferences.d/thunderbird-ppa
    sudo apt-get update -y
    sudo apt-get install --allow-downgrades thunderbird -y

}

install_shell() {
    echo "  - Installing Fish Shell"
    sudo apt-get install fish -y
    command -v fish | sudo tee -a /etc/shells
    chsh -s "$(command -v fish)"
}

install_xfce () {
    echo "Installing desktop env (xfce).."
    sudo apt-get install xfce4 xfce4-goodies -y
}

install_display_settings() {
    echo "Setting up display settings..."
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    mkdir -p ${BACKGROUND_IMAGE_TARGET}
    cp --update=none ${BACKGROUND_IMAGE_SOURCE} ${BACKGROUND_IMAGE_TARGET}/${BACKGROUND_IMAGE}
    gsettings set org.gnome.desktop.background picture-uri-dark "file:///${BACKGROUND_IMAGE_TARGET}/${BACKGROUND_IMAGE}"
}

MODE=""
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

if [ -z "$MODE" ]; then
    show_help >&2
    echo "Error: -i option is required" >&2
    exit 1
fi

test -d "${LOG_DIR}" || mkdir ${LOG_DIR}
exec > >(tee -a "$LOG_FILE") 2>&1

if [ "$MODE" != "all" ] && [ -z "${SETUP_OPTIONS[$MODE]}" ]; then
    show_help >&2
    exit 1
fi

echo "Setting up Ubuntu.."

if [ "$MODE" = "all" ]; then
    for option in "${SETUP_ORDER[@]}"; do
        "${SETUP_OPTIONS[$option]}"
    done
else
    "${SETUP_OPTIONS[$MODE]}"
fi

echo "Setup complete"