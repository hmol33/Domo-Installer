# Domo-Installer

[![CI](https://github.com/hmol33/Domo-Installer/actions/workflows/ci.yml/badge.svg)](https://github.com/hmol33/Domo-Installer/actions)
[![Stars](https://img.shields.io/github/stars/hmol33/Domo-Installer?style=flat-square&color=blue)](https://github.com/hmol33/Domo-Installer/stargazers)
[![License](https://img.shields.io/github/license/hmol33/Domo-Installer?style=flat-square)](LICENSE)

Een (menu)script dat je een geleide installatie geeft voor Domoticz.

## Vereisten

- Debian of Ubuntu (armv7l)
- sudo rechten
- whiptail (standaard geïnstalleerd)
- Internetverbinding

## Installatie

```bash
bash <(curl -Ls https://github.com/hmol33/Domo-Installer/raw/master/Domo-Installer.sh)
```

## Opties

| Optie | Beschrijving |
|-------|-------------|
| 1) | Installeer Domoticz (Release) |
| 2) | Installeer Domoticz (Beta) |
| 3) | Installeer Domoticz (Sourcecode) |
| 4) | Update Domoticz |
| 5) | Backup Domoticz (nog niet geïmplementeerd) |

## Gebruik

Na installatie: start Domoticz met `sudo /etc/init.d/domoticz.sh start`

## Bijdragers

- [hmol33](https://github.com/hmol33) — Onderhouder

## Licentie

MIT — zie [LICENSE](LICENSE) voor details.
