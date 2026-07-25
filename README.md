# Luckfox Pico Plus Ubuntu

Reproduzierbares Projekt zum Erstellen und Anpassen eines Ubuntu-Images
für den Luckfox Pico Plus.

## Ziele

- Ubuntu 22.04 als Root-Dateisystem
- Boot von microSD
- vergrößertes Root-Dateisystem
- SSH-Zugang
- apt-Paketverwaltung
- Git, Python und Build-Werkzeuge
- reproduzierbare Build- und Flash-Anleitung

## Build-Umgebung

- Windows 11
- WSL2
- Ubuntu 22.04 x86_64
- offizielles Luckfox Pico SDK

## Schnellstart

```bash
./scripts/setup-wsl.sh
./scripts/clone-sdk.sh
