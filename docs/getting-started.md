---
title: Getting Started
description: Build Ubuntu 22.04 for the Luckfox Pico Plus from scratch.
---

# Getting Started

This guide walks you through the complete setup required to build Ubuntu 22.04 for the Luckfox Pico Plus.

The objective is to generate a complete, bootable firmware package that can be written to a microSD card using the Luckfox SocToolKit.

---

# Build Host Requirements

The project is developed and tested on the following environment:

| Component | Version |
|----------|---------|
| Windows | 11 |
| WSL | Version 2 |
| Ubuntu | 22.04 LTS |
| Git | Latest |
| Python | 3.x |
| Luckfox SDK | Official SDK |

Native Ubuntu Linux should work as well, although WSL2 is the primary development platform.

---

# Hardware Requirements

Required hardware:

- Luckfox Pico Plus (RV1103)
- microSD card (8 GB or larger)
- USB-C cable
- USB to TTL serial adapter (recommended)
- Ethernet connection

Optional:

- Logic analyzer
- USB Ethernet adapter
- SD card reader

---

# Clone the Repository

Clone the project into your Linux home directory.

> **Important:**  
> Do **not** build the project inside `/mnt/c/...`.
> Building inside the native Linux filesystem significantly improves performance and avoids timestamp issues.

```bash
cd ~

git clone https://github.com/okoebernik/luckfox-pico-plus-ubuntu.git

cd luckfox-pico-plus-ubuntu
```

---

# Install Required Packages

Install all required build dependencies.

```bash
./scripts/setup-wsl.sh
```

The setup script installs packages including:

- debootstrap
- qemu-user-static
- rsync
- git
- curl
- wget
- build-essential

---

# Download the Luckfox SDK

Clone the official Luckfox SDK.

```bash
./scripts/clone-sdk.sh
```

After completion the repository should contain:

```text
sdk/
rootfs/
scripts/
config/
docs/
output/
```

---

# Build Ubuntu

The entire build process is started with a single command.

```bash
./scripts/build-all.sh
```

The build process performs the following steps automatically:

1. Optimize the Ubuntu root filesystem
2. Install kernel modules
3. Generate `rootfs.img`
4. Collect firmware images
5. Create the release package
6. Generate release metadata

---

# Build Output

After a successful build the following directory is created:

```text
output/release/
```

Typical contents:

```text
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

---

# Flash the SD Card

Use the official Luckfox SocToolKit.

Open:

```text
output/release/
```

and write the generated images to a microSD card.

Detailed instructions can be found in:

> **flashing.md**

---

# First Boot

Insert the microSD card into the Luckfox Pico Plus.

Connect:

- Ethernet
- USB power
- Serial adapter (recommended)

Wait approximately one minute.

The board should obtain an IP address from your DHCP server.

Login via SSH:

```bash
ssh pico@<board-ip>
```

or use the serial console.

---

# Verify the Installation

After the first login verify the system:

```bash
free -h

swapon --show

df -h

ip a

uname -a
```

Expected results:

- Ubuntu 22.04
- Linux 5.10.x
- Ethernet active
- Swap enabled
- SSH operational

---

# Recommended Next Steps

Continue with:

- **build-system.md**
- **flashing.md**
- **first-boot.md**
- **memory-optimization.md**

These guides explain the complete build pipeline and the design decisions behind the project.