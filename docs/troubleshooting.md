---
title: Troubleshooting
description: Diagnose and resolve common issues on Ubuntu 22.04 for the Luckfox Pico Plus.
version: v0.1.0
---

# Ubuntu 22.04 for Luckfox Pico Plus

## Troubleshooting Guide (Part 1)

> This document is Part 1 of the engineering troubleshooting manual.

| Previous | Home | Next |
|-----------|------|------|
| [← Memory Optimization](memory-optimization.md) | README | Part 2 → |

---

# Table of Contents

1. Troubleshooting Philosophy
2. Where is the Failure?
3. Boot Overview
4. Boot Problems
5. UART Problems
6. SSH Problems
7. Network Problems
8. Diagnostic Workflow
9. First Diagnostic Commands
10. Quick Reference

---

# Troubleshooting Philosophy

Troubleshooting should always follow the system stack instead of guessing.

```
Power
 ↓
BootROM
 ↓
U-Boot
 ↓
Linux Kernel
 ↓
systemd
 ↓
Network
 ↓
SSH
 ↓
User
```

Always determine the **highest layer that still works**.

---

# Where is the Failure?

| Symptom | Failure Layer |
|----------|---------------|
| No LEDs | Power |
| No UART output | BootROM / Hardware |
| U-Boot starts | Bootloader |
| Kernel panic | Linux Kernel / RootFS |
| Login prompt missing | systemd |
| SSH unavailable | Network / SSH |
| Login killed | Memory / OOM |

---

# Boot Problems

## No Power

Check:

- USB-C power supply
- Cable
- Board LEDs
- USB current capability

---

## No UART Output

Verify:

- UART2 wiring
- 115200 baud
- RX/TX crossed
- Common GND

---

## U-Boot Starts but Kernel Does Not

Possible causes:

- damaged `boot.img`
- corrupted `rootfs.img`
- incomplete flash

Recommended action:

1. Verify SHA256 checksums.
2. Reflash the complete release package.

---

# UART Problems

Typical settings:

```
115200
8 data bits
No parity
1 stop bit
No flow control
```

If the terminal remains empty:

- verify adapter voltage (3.3 V TTL)
- verify UART2 pins
- try another USB adapter

---

# SSH Problems

Diagnostic sequence:

1. Can the board be pinged?
2. Is TCP port 22 reachable?
3. Is `ssh.service` running?
4. Check:

```bash
sudo systemctl status ssh
sudo journalctl -u ssh -b
```

If the SSH daemon exits unexpectedly, inspect the kernel log for OOM events.

---

# Network Problems

Useful commands:

```bash
ip address
ip route
ping <gateway>
```

Verify:

- DHCP address assigned
- Default route present
- Link LEDs active

---

# Diagnostic Workflow

```
Observe
   ↓
Collect Logs
   ↓
Identify Layer
   ↓
Analyze
   ↓
Fix
   ↓
Verify
```

---

# First Diagnostic Commands

```bash
uname -a
cat /etc/os-release
free -h
swapon --show
ip address
ip route
systemctl --failed
journalctl -b
dmesg
lsblk
mount
df -h
```

---

# Quick Reference

```
Power
 ↓
UART
 ↓
Kernel
 ↓
Network
 ↓
SSH
 ↓
Login
```

Part 2 will cover:

- Kernel Panic
- RootFS recovery
- Flash recovery
- Build failures
- OOM diagnostics
- GitHub issue collection
- Recovery procedures
