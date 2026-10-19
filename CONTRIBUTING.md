# Contributing to Domo-Installer

Bedankt voor je interesse om bij te dragen aan Domo-Installer!

## Hoe kan ik bijdragen?

### Bugs rapporteren

1. Controleer eerst of de bug al is gerapporteerd in de [Issues](https://github.com/hmol33/Domo-Installer/issues)
2. Maak een nieuwe issue aan met:
   - Een duidelijke titel
   - Stappen om de bug te reproduceren
   - Verwacht vs. werkelijk gedrag
   - Je OS (Raspberry Pi model, OS-versie)
   - Relevante log-output

### Features voorstellen

1. Open eerst een issue om de feature te bespreken
2. Wacht op goedkeuring voordat je code schrijft
3. Kleine, gefocuste features hebben voorkeur

### Pull Requests

1. Fork de repo en maak een feature-branch aan
2. Zorg dat je changes werken op zowel Raspberry Pi (armv7l) als x86
3. Test je changes lokaal voordat je pusht
4. Maak een PR aan met een duidelijke beschrijving van wat en waarmee

## Code Stijl

- Gebruik `bash` (geen `sh`)
- Voeg comments toe aan nieuwe menu-opties
- Test met `shellcheck` voordat je pusht:
  ```bash
  shellcheck Domo-Installer.sh
  ```

## Ontwikkelomgeving

```bash
# Clone de repo
git clone https://github.com/hmol33/Domo-Installer.git
cd Domo-Installer

# Maak een test-branch aan
git checkout -b feature/mijn-feature

# Test lokaal (op een Raspberry Pi of ARM-emulator)
bash Domo-Installer.sh
```

## Licentie

Door bij te dragen ga je akkoord dat je bijdragen onder de MIT-licentie worden uitgebracht.
