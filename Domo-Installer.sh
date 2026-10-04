#!/bin/bash
#
# Domo-Installer — Geleide installatie voor Domoticz
#
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()   { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

install_deps() {
    log "Installeren van dependencies..."
    sudo apt-get update -qq
    sudo apt-get install -y build-essential cmake libboost-dev libboost-thread-dev \
        libboost-system-dev libsqlite3-dev subversion curl libcurl4-openssl-dev \
        libusb-dev libudev-dev zlib1g-dev libssl-dev
}

install_release() {
    log "Downloaden van Domoticz release..."
    install_deps
    wget https://releases.domoticz.com/releases/release/domoticz_linux_armv7l.tgz
    tar -xvzf domoticz_linux_armv7l.tgz
    cd domoticz
    log "Domoticz release geinstalleerd in $(pwd)"
}

install_beta() {
    log "Downloaden van Domoticz beta..."
    install_deps
    wget https://releases.domoticz.com/releases/beta/domoticz_linux_armv7l.tgz
    tar -xvzf domoticz_linux_armv7l.tgz
    cd domoticz
    log "Domoticz beta geinstalleerd in $(pwd)"
}

install_source() {
    log "Installeren van Domoticz uit source..."
    install_deps
    cd ~
    if [[ ! -d domoticz ]]; then
        git clone https://github.com/domoticz/domoticz.git ~/domoticz
    fi
    cd ~/domoticz
    cmake -DCMAKE_BUILD_TYPE=Beta .
    make -j$(nproc)
    cd ~
    wget http://archive.debian.org/debian/pool/main/o/openssl/libssl1.0.0_1.0.2l-1~bpo8+1_armhf.deb
    sudo dpkg -i libssl1.0.0_1.0.2l-1~bpo8+1_armhf.deb
    sudo usermod -a -G dialout "$USER"
    cd ~/domoticz
    ${EDITOR:-nano} domoticz.sh
    sudo cp domoticz.sh /etc/init.d
    sudo chmod +x /etc/init.d/domoticz.sh
    sudo update-rc.d domoticz.sh defaults
    sudo ${EDITOR:-nano} /etc/init.d/domoticz.sh
    log "Domoticz uit source geinstalleerd."
}

update_domoticz() {
    log "Updaten van Domoticz..."
    cd ~/domoticz/
    sudo /etc/init.d/domoticz.sh stop
    git pull
    make -j$(nproc)
    sudo /etc/init.d/domoticz.sh start
    log "Domoticz geupdate."
}

backup_domoticz() {
    warn "Backup is nog niet geimplementeerd."
}

MENU() {
    while true; do
        CHOICE=$(
            whiptail --title "Operative Systems" --menu "Make your choice" 16 100 9 \
                "1)" "Install Domoticz (Release)."   \
                "2)" "Install Domoticz. (Beta)"  \
                "3)" "Install Domoticz. (Sourcecode)" \
                "4)" "Update Domoticz." \
                "5)" "Backup Domoticz." \
                "exit)" "End script"  3>&2 2>&1 1>&3
        )

        case $CHOICE in
            "1)")
                whiptail --msgbox "Installeren van Domoticz release..." 20 78
                install_release
                ;;
            "2)")
                whiptail --msgbox "Installeren van Domoticz beta..." 20 78
                install_beta
                ;;
            "3)")
                whiptail --msgbox "Installeren van Domoticz uit source..." 20 78
                install_source
                ;;
            "4)")
                whiptail --msgbox "Updaten van Domoticz..." 20 78
                update_domoticz
                ;;
            "5)")
                whiptail --msgbox "Backup van Domoticz..." 20 78
                backup_domoticz
                ;;
            "exit)")
                whiptail --msgbox "Afsluiten..." 20 78
                exit 0
                ;;
        esac
    done
}

if whiptail --title "Install Domoticz" --yesno "This script will install domoticz. are you sure?" 8 78; then
    log "User selected Yes, exit status was $?."
    MENU
else
    log "User selected No, exit status was $?."
    exit 0
fi
