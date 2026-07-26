# Ubuntu 22.04 for Luckfox Pico Plus

> A reproducible Ubuntu 22.04 build environment for the **Luckfox Pico Plus (RV1103)** based on the official Luckfox SDK.

<p align="center">

![Status](https://img.shields.io/badge/status-experimental-orange)
![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04-E95420)
![Kernel](https://img.shields.io/badge/Linux-5.10.160-blue)
![Architecture](https://img.shields.io/badge/Architecture-ARMHF-success)

</p>

<p align="center">
  <img src="docs/images/luckfox-ubuntu-architecture.svg"
       alt="Luckfox Ubuntu Build Architecture"
       width="100%">
</p>

---

## Overview

The **Luckfox Pico Plus** is an incredibly capable embedded Linux platform based on the **Rockchip RV1103**.

The official Luckfox SDK already provides an excellent Buildroot-based firmware including the Linux kernel, bootloader and hardware support.

This project extends the official SDK with a fully automated **Ubuntu 22.04 LTS** userspace while intentionally preserving the vendor boot chain.

Instead of replacing the SDK, it combines:

- **Official Luckfox SDK**
  - U-Boot
  - Linux Kernel
  - Device Tree
  - Hardware Drivers

with

- **Ubuntu 22.04 LTS**
  - ARMHF userspace
  - apt package manager
  - OpenSSH
  - Standard Ubuntu development environment

The result is a lightweight Ubuntu-based embedded Linux system that boots directly from a microSD card while remaining fully compatible with the official Luckfox SDK.

---

# Project at a Glance

| Component | Value |
|-----------|-------|
| Board | Luckfox Pico Plus |
| SoC | Rockchip RV1103 |
| Userspace | Ubuntu 22.04 LTS |
| Kernel | Linux 5.10.160 |
| Architecture | ARMHF |
| Boot Medium | microSD |
| Package Manager | apt |
| Build Host | Ubuntu 22.04 / WSL2 |

---

# Why this project?

The primary goal is **not** to replace the official Luckfox SDK.

Instead, this project provides a reproducible and maintainable Ubuntu environment while continuing to use the original Rockchip kernel, bootloader and board support package.

This makes it significantly easier to

- develop Linux applications
- install software using `apt`
- use familiar Ubuntu development tools
- prototype embedded applications
- build IoT gateways
- create automation systems

without maintaining a custom Buildroot configuration.

---

# Features

- Ubuntu 22.04 LTS (Jammy Jellyfish)
- ARMHF userspace
- Linux 5.10.160 from the official Luckfox SDK
- Ethernet networking
- OpenSSH server
- apt package management
- Automated Ubuntu root filesystem generation
- Automated firmware packaging
- Automated release pipeline
- Swap support for low-memory systems
- Optimized systemd configuration
- SHA-256 verification
- Fully reproducible builds

---

# Current Status

| Component | Status |
|-----------|--------|
| Ubuntu 22.04 | ✅ |
| Linux Kernel | ✅ |
| Ethernet | ✅ |
| SSH | ✅ |
| apt | ✅ |
| SD Card Boot | ✅ |
| Automated Build Pipeline | ✅ |
| Release Packaging | ✅ |
| GPIO Documentation | 🚧 |
| Camera Support | 🚧 |
| CI/CD | 🚧 |

---

# Documentation

The complete documentation is available inside the **docs** directory.

| Guide | Description |
|--------|-------------|
| Introduction | Project goals, motivation and architecture |
| Getting Started | Build your first Ubuntu image |
| Build System | Complete firmware build pipeline |
| Flashing | Create a bootable microSD card |
| First Boot | Initial startup and verification |
| Memory Optimization | Running Ubuntu on a 32 MiB system |
| Troubleshooting | Common problems and solutions |
| Development | Repository layout and contribution guide |

---

# Build Architecture

The complete firmware generation process is illustrated below.

<p align="center">
  <img src="docs/images/luckfox-ubuntu-build-pipeline.svg"
       alt="Luckfox Ubuntu Build Pipeline"
       width="100%">
</p>

---

# Quick Start

Clone the repository

```bash
git clone https://github.com/okoebernik/luckfox-pico-plus-ubuntu.git

cd luckfox-pico-plus-ubuntu
```

Install the build environment

```bash
./scripts/setup-wsl.sh
```

Download the official Luckfox SDK

```bash
./scripts/clone-sdk.sh
```

Build Ubuntu

```bash
./scripts/build-all.sh
```

The generated firmware package will be available in

```text
output/release/
```

---

# Build Output

The release directory contains:

```text
output/release/

boot.img
download.bin
env.img
idblock.img
rootfs.img
uboot.img
userdata.img

SHA256SUMS
manifest.txt
```

These files can be imported directly into the official Luckfox SocToolKit.

---

# Roadmap

## Version 0.1

- Ubuntu Boot
- SSH
- apt
- Release Pipeline
- Documentation

## Version 0.2

- GPIO Helper Library
- Camera Support
- Memory Optimizations
- Improved Documentation

## Version 1.0

- Stable Release
- Complete Documentation
- GitHub Actions
- Automated Testing

---

# Contributing

Contributions are welcome.

If you would like to improve the project, please read

- CONTRIBUTING.md

before opening a Pull Request.

Bug reports and feature requests are highly appreciated.

---

# License

This project is released under the MIT License.

See the LICENSE file for details.