#!/bin/bash
set -euo pipefail

# Domo-Installer: geleide installatie voor Domoticz
# Gebruik: bash Domo-Installer.sh

check_deps() {
  local missing=()
  command -v whiptail >/dev/null 2>&1 || missing+=("whiptail")
  command -v wget >/dev/null 2>&1 || missing+=("wget")
  command -v git >/dev/null 2>&1 || missing+=("git")
  if [ ${#missing[@]} -gt 0 ]; then
    echo "Ontbrekende dependencies: ${missing[*]}"
    echo "Installeer met: sudo apt-get install whiptail wget git"
    exit 1
  fi
}

install_deps() {
  echo "Installing dependencies..."
  sudo apt-get update
  sudo apt-get install -y build-essential cmake libboost-dev libboost-thread-dev \
    libboost-system-dev libsqlite3-dev subversion curl libcurl4-openssl-dev \
    libusb-dev libudev-dev zlib1g-dev libssl-dev
}

install_release() {
  install_deps
  local tmpdir
  tmpdir=$(mktemp -d)
  cd "$tmpdir"
  wget https://releases.domoticz.com/releases/release/domoticz_linux_armv7l.tgz
  tar -xvzf domoticz_linux_armv7l.tgz
  cd domoticz
  sudo cp -r * /opt/domoticz/
  cd ~
  rm -rf "$tmpdir"
  whiptail --msgbox "Domoticz Release geïnstalleerd in /opt/domoticz/" 20 78
}

install_beta() {
  install_deps
  local tmpdir
  tmpdir=$(mktemp -d)
  cd "$tmpdir"
  wget https://releases.domoticz.com/releases/beta/domoticz_linux_armv7l.tgz
  tar -xvzf domoticz_linux_armv7l.tgz
  cd domoticz
  sudo cp -r * /opt/domoticz/
  cd ~
  rm -rf "$tmpdir"
  whiptail --msgbox "Domoticz Beta geïnstalleerd in /opt/domoticz/" 20 78
}

install_source() {
  install_deps
  cd ~
  git clone https://github.com/domoticz/domoticz.git ~/domoticz
  cd ~/domoticz
  cmake -DCMAKE_BUILD_TYPE=Release .
  make -j$(nproc)
  sudo make install
  sudo usermod -a -G dialout "$USER"
  whiptail --msgbox "Domoticz uit source geïnstalleerd. Voer 'domoticz' uit om te starten." 20 78
}

update_domoticz() {
  if [ ! -d ~/domoticz ]; then
    whiptail --msgbox "Domoticz source niet gevonden in ~/domoticz/" 20 78
    return
  fi
  cd ~/domoticz
  git pull
  make -j$(nproc)
  sudo make install
  whiptail --msgbox "Domoticz geüpdatet." 20 78
}

backup_domoticz() {
  local backup_dir="$HOME/domoticz-backup-$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$backup_dir"
  if [ -d ~/domoticz ]; then
    cp -r ~/domoticz "$backup_dir/source"
  fi
  if [ -d /opt/domoticz ]; then
    cp -r /opt/domoticz "$backup_dir/installed"
  fi
  whiptail --msgbox "Backup gemaakt in $backup_dir" 20 78
}

MENU(){
  while true; do
    local CHOICE
    CHOICE=$(whiptail --title "Domo-Installer" --menu "Maak je keuze" 16 100 9 \
      "1)" "Installeer Domoticz (Release)." \
      "2)" "Installeer Domoticz (Beta)." \
      "3)" "Installeer Domoticz (Sourcecode)." \
      "4)" "Update Domoticz." \
      "5)" "Backup Domoticz." \
      "exit)" "Stop script." 3>&1 1>&2 2>&3)

    case $CHOICE in
      "1)") install_release ;;
      "2)") install_beta ;;
      "3)") install_source ;;
      "4)") update_domoticz ;;
      "5)") backup_domoticz ;;
      "exit)" |"")
        whiptail --msgbox "Tot ziens!" 20 78
        exit 0
        ;;
    esac
  done
}

check_deps
MENU

if (whiptail --title "Install Domoticz" --yesno "This script will install domoticz. are you sure?" 8 78) then
    echo "User selected Yes, exit status was $?."
    MENU
else
    echo "User selected No, exit status was $?."
    exit
fi
