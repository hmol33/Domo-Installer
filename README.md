# Domo-Installer

<img src="https://img.shields.io/github/stars/hmol33/Domo-Installer?style=flat-square&color=blue" alt="Stars">
<img src="https://img.shields.io/github/forks/hmol33/Domo-Installer?style=flat-square&color=green" alt="Forks">
<img src="https://img.shields.io/github/license/hmol33/Domo-Installer?style=flat-square" alt="License">
<img src="https://github.com/hmol33/Domo-Installer/workflows/CI/badge.svg" alt="CI">

Een (menu)script dat je een geleide installatie geeft voor Domoticz.

## Installatie

```bash
bash <(curl -Ls https://github.com/hmol33/Domo-Installer/raw/master/Domo-Installer.sh)
```

## Gebruik

```bash
# Voer het installatiescript uit
bash <(curl -Ls https://github.com/hmol33/Domo-Installer/raw/master/Domo-Installer.sh)

# Volg de menu-instructies op het scherm
```

## Opties

| Variabele | Default | Beschrijving |
|-----------|---------|--------------|
| `DRY_RUN` | (leeg) | Zet op `1` voor dry-run mode (geen wijzigingen) |
| `LOG_FILE` | `/tmp/domo-installer.log` | Pad naar log bestand |
| `DOMOTICZ_DIR` | `$HOME/domoticz` | Domoticz directory |

### Voorbeelden

```bash
# Dry-run (test zonder wijzigingen)
DRY_RUN=1 bash <(curl -Ls https://github.com/hmol33/Domo-Installer/raw/master/Domo-Installer.sh)

# Custom domoticz directory
DOMOTICZ_DIR=/opt/domoticz bash <(curl -Ls https://github.com/hmol33/Domo-Installer/raw/master/Domo-Installer.sh)
```

## Features

- Whiptail menu voor interactieve installatie
- Automatische dependency check
- Error handling met cleanup trap
- DRY_RUN mode voor veilig testen
- Structured logging
- GitHub Actions CI (shellcheck)
- Ondersteunt: Release, Beta, Source, Update, Backup

## Bijdragers

- [hmol33](https://github.com/hmol33) — Onderhouder

## Licentie

MIT — zie [LICENSE](LICENSE) voor details.
