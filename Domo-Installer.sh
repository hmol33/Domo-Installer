#!/bin/bash
set -euo pipefail

# Domo-Installer — Verbeterde versie
# Geeft een geleide installatie voor Domoticz via whiptail menu

# ─── Configuratie ──────────────────────────────────────────────────────────────
DRY_RUN="${DRY_RUN:-}"
LOG_FILE="${LOG_FILE:-/tmp/domo-installer.log}"
DOMOTICZ_DIR="${DOMOTICZ_DIR:-$HOME/domoticz}"

# ─── Logging ──────────────────────────────────────────────────────────────────
log() {
    local level="$1"
    shift
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*"
    echo "$msg"
    echo "$msg" >> "$LOG_FILE" 2>/dev/null || true
}

info()  { log "INFO" "$@"; }
warn()  { log "WARN" "$@"; }
error() { log "ERROR" "$@"; }

# ─── DRY_RUN helper ───────────────────────────────────────────────────────────
run() {
    if [ -n "$DRY_RUN" ]; then
        info "[DRY-RUN] Would run: $*"
        return 0
    fi
    "$@"
}

# ─── Dependency check ─────────────────────────────────────────────────────────
check_dependencies() {
    local deps=("whiptail" "git" "cmake" "make" "gcc" "g++" "wget" "curl")
    local missing=()

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            missing+=("$dep")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        error "Ontbrekende dependencies: ${missing[*]}"
        info "Installeer met: sudo apt-get install ${missing[*]}"
        exit 1
    fi

    info "Alle dependencies aanwezig"
}

# ─── Error handler ────────────────────────────────────────────────────────────
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        error "Installatie mislukt met exit code $exit_code"
        error "Bekijk log: $LOG_FILE"
    fi
    exit $exit_code
}
trap cleanup EXIT

# ─── Installatie functies ─────────────────────────────────────────────────────
install_dependencies() {
    info "Dependencies installeren..."
    run sudo apt-get update -qq
    run sudo apt-get install -y -qq build-essential cmake libboost-dev libboost-thread-dev \
        libboost-system-dev libsqlite3-dev subversion curl libcurl4-openssl-dev \
        libusb-dev libudev-dev zlib1g-dev libssl-dev whiptail
}

install_release() {
    info "Domoticz Release installeren..."
    install_dependencies

    local tmpdir
    tmpdir=$(mktemp -d)
    cd "$tmpdir"

    run wget https://releases.domoticz.com/releases/release/domoticz_linux_armv7l.tgz
    run tar -xvzf domoticz_linux_armv7l.tgz
    run sudo cp -r domoticz /opt/
    run sudo ln -sf /opt/domoticz/domoticz.sh /usr/local/bin/domoticz

    cd -
    rm -rf "$tmpdir"

    info "Domoticz Release geïnstalleerd in /opt/domoticz"
}

install_beta() {
    info "Domoticz Beta installeren..."
    install_dependencies

    local tmpdir
    tmpdir=$(mktemp -d)
    cd "$tmpdir"

    run wget https://releases.domoticz.com/releases/beta/domoticz_linux_armv7l.tgz
    run tar -xvzf domoticz_linux_armv7l.tgz
    run sudo cp -r domoticz /opt/
    run sudo ln -sf /opt/domoticz/domoticz.sh /usr/local/bin/domoticz

    cd -
    rm -rf "$tmpdir"

    info "Domoticz Beta geïnstalleerd in /opt/domoticz"
}

install_source() {
    info "Domoticz van source installeren..."
    install_dependencies

    if [ ! -d "$DOMOTICZ_DIR" ]; then
        run git clone https://github.com/domoticz/domoticz.git "$DOMOTICZ_DIR"
    fi

    cd "$DOMOTICZ_DIR"
    run cmake -DCMAKE_BUILD_TYPE=Release .
    run make -j"$(nproc)"
    run sudo make install

    info "Domoticz van source geïnstalleerd"
}

update_domoticz() {
    info "Domoticz updaten..."
    if [ ! -d "$DOMOTICZ_DIR" ]; then
        error "Domoticz niet gevonden in $DOMOTICZ_DIR"
        exit 1
    fi

    cd "$DOMOTICZ_DIR"
    run git pull
    run make -j"$(nproc)"
    run sudo make install

    info "Domoticz geüpdatet"
}

backup_domoticz() {
    info "Domoticz backuppen..."
    if [ ! -d "$DOMOTICZ_DIR" ]; then
        error "Domoticz niet gevonden in $DOMOTICZ_DIR"
        exit 1
    fi

    local backup_file="domoticz-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    run tar -czf "$backup_file" -C "$(dirname "$DOMOTICZ_DIR")" "$(basename "$DOMOTICZ_DIR")"
    info "Backup opgeslagen als: $backup_file"
}

# ─── Menu ─────────────────────────────────────────────────────────────────────
MENU() {
    while true; do
        local CHOICE
        CHOICE=$(
            whiptail --title "Domo-Installer" --menu "Maak je keuze" 16 100 9 \
                "1)" "Install Domoticz (Release)." \
                "2)" "Install Domoticz (Beta)." \
                "3)" "Install Domoticz (Sourcecode)." \
                "4)" "Update Domoticz." \
                "5)" "Backup Domoticz." \
                "exit)" "End script" 3>&2 2>&1 1>&3
        )

        case "$CHOICE" in
            "1)")
                whiptail --msgbox "Installeren van Domoticz Release..." 20 78
                install_release
                ;;
            "2)")
                whiptail --msgbox "Installeren van Domoticz Beta..." 20 78
                install_beta
                ;;
            "3)")
                whiptail --msgbox "Installeren van Domoticz van source..." 20 78
                install_source
                ;;
            "4)")
                whiptail --msgbox "Updaten van Domoticz..." 20 78
                update_domoticz
                ;;
            "5)")
                whiptail --msgbox "Backuppen van Domoticz..." 20 78
                backup_domoticz
                ;;
            "exit)")
                whiptail --msgbox "Tot ziens!" 20 78
                exit 0
                ;;
        esac
    done
}

# ─── Hoofdprogramma ───────────────────────────────────────────────────────────
main() {
    info "=== Domo-Installer gestart ==="
    info "Log bestand: $LOG_FILE"

    if [ -n "$DRY_RUN" ]; then
        info "DRY-RUN mode — er worden geen wijzigingen aangebracht"
    fi

    check_dependencies

    if whiptail --title "Domo-Installer" --yesno "Dit script installeert Domoticz. Weet je het zeker?" 8 78; then
        info "User selected Yes"
        MENU
    else
        info "User selected No — exiting"
        exit 0
    fi
}

main "$@"
