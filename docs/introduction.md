---
title: Introduction
description: Motivation, goals and architecture of Ubuntu 22.04 for the Luckfox Pico Plus.
version: v0.1.0
---

<p align="center">

# Ubuntu 22.04 for Luckfox Pico Plus

### Introduction

<img src="images/luckfox-ubuntu-architecture.svg"
     alt="Luckfox Ubuntu Architecture"
     width="100%">

</p>

> [!NOTE]
> This document introduces the project, explains its motivation and describes the overall architecture before diving into the implementation details.

| Previous | Home | Next |
|-----------|------|------|
| ← README | [README](../README.md) | Getting Started → |

---

# Table of Contents

- Motivation
- Why Ubuntu?
- Project Goals
- Architecture
- Design Principles
- Current Status
- Repository Structure
- Next Steps

---

# Motivation

The **Luckfox Pico Plus** is a remarkably capable embedded Linux platform based on the Rockchip **RV1103** SoC.

The official Luckfox SDK already provides an excellent Buildroot-based operating system together with a modern Linux kernel, bootloader, device tree and complete hardware support.

For many embedded products this is exactly the right solution.

However, application development often requires a more familiar Linux userspace.

Typical examples include:

- Python development
- C/C++ application development
- Network services
- REST APIs
- MQTT gateways
- Home automation
- Rapid software prototyping

While all of these applications can be implemented using Buildroot, maintaining a custom Buildroot configuration quickly becomes time-consuming.

Ubuntu already provides thousands of precompiled packages through `apt`, making application development significantly easier.

This project combines the flexibility of Ubuntu with the stability of the official Luckfox SDK.

---

# Why Ubuntu?

Ubuntu is one of the most widely used Linux distributions in embedded development.

It provides:

- long-term support (LTS)
- excellent package availability
- familiar development tools
- large community support
- reliable security updates

Rather than rebuilding the operating system every time a package changes, software can simply be installed using:

```bash
sudo apt install <package>
```

This dramatically reduces development time.

---

# Project Goals

The project follows several important design goals.

## Reproducible

Every firmware image should be reproducible from source.

Running

```bash
./scripts/build-all.sh
```

should always generate the same release.

---

## Compatible

The project intentionally keeps the official Luckfox SDK unchanged.

The following components remain vendor supplied:

- BootROM
- idblock
- U-Boot
- Linux kernel
- Device Tree
- Hardware drivers

Ubuntu replaces only the userspace.

---

## Automated

The complete build process is automated.

Individual scripts perform:

- Ubuntu optimization
- Kernel module integration
- Root filesystem generation
- Firmware packaging
- Release creation

---

## Lightweight

The Luckfox Pico Plus provides only approximately **32 MiB RAM**.

Running Ubuntu on such a platform requires careful optimization.

Examples include:

- swap support
- reduced systemd footprint
- disabled maintenance timers
- volatile logging
- optimized memory usage

---

# Overall Architecture

The following diagram illustrates the relationship between the official SDK and the Ubuntu userspace.

<p align="center">

<img src="images/luckfox-ubuntu-architecture.svg"
     alt="Luckfox Ubuntu Architecture"
     width="100%">

</p>

The project consists of two independent parts.

## Official Luckfox SDK

Provides:

- Bootloader
- Linux kernel
- Device Tree
- Drivers
- Firmware tools

These components remain unchanged.

---

## Ubuntu Userspace

Provides:

- Ubuntu 22.04 LTS
- ARMHF userspace
- apt package manager
- OpenSSH
- systemd
- Standard Linux environment

The userspace is generated automatically using `debootstrap`.

---

# Design Principles

The project deliberately separates hardware support from the operating system.

This architecture offers several advantages:

- easier SDK updates
- fewer vendor modifications
- reproducible builds
- simpler debugging
- long-term maintainability

Whenever possible, improvements are implemented entirely inside the Ubuntu userspace.

---

# Current Status

| Component | Status |
|-----------|--------|
| Ubuntu 22.04 | ✅ |
| Linux Kernel | ✅ |
| Ethernet | ✅ |
| SSH | ✅ |
| apt | ✅ |
| Automated Build | ✅ |
| Release Pipeline | ✅ |
| Memory Optimization | ✅ |
| GPIO Documentation | 🚧 |
| Camera Support | 🚧 |
| CI/CD | 🚧 |

---

# Repository Structure

The repository is organized into several logical components.

```text
README.md

config/
    Project configuration

docs/
    Documentation

docs/images/
    Diagrams

scripts/
    Build automation

sdk/
    Official Luckfox SDK

rootfs/
    Generated Ubuntu filesystem

output/
    Generated firmware
```

Only generated artifacts are excluded from version control.

---

# Documentation

The project documentation is organized into multiple guides.

| Document | Description |
|-----------|-------------|
| Getting Started | Initial project setup |
| Build System | Complete build pipeline |
| Flashing | Creating a bootable SD card |
| First Boot | Initial startup |
| Memory Optimization | Running Ubuntu on low-memory hardware |
| Troubleshooting | Known issues and solutions |

---

# Next Steps

Continue with **Getting Started** to prepare your development environment and build your first Ubuntu firmware image.

---

## Continue Reading

| Previous | Home | Next |
|-----------|------|------|
| ← README | [README](../README.md) | Getting Started → |

---