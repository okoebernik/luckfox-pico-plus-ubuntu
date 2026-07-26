---
title: Troubleshooting (Part 2)
description: Advanced recovery procedures and engineering diagnostics.
version: v0.1.0
---

# Ubuntu 22.04 for Luckfox Pico Plus

## Troubleshooting Guide (Part 2)

This chapter continues the troubleshooting guide with advanced recovery techniques.

---

# Table of Contents

1. Kernel Panic
2. RootFS Recovery
3. Flash Recovery
4. Build Failures
5. Memory / OOM Diagnostics
6. SD Card Diagnostics
7. Collecting Logs
8. GitHub Issue Checklist
9. Recovery Procedures
10. Engineering Notes

---

# Kernel Panic

Typical symptoms:

- `Kernel panic - not syncing`
- `Unable to mount root fs`
- endless reboot loop

## Verify

```bash
dmesg | tail -100
cat /proc/cmdline
mount
lsblk
```

Common causes:

- damaged `boot.img`
- incorrect kernel command line
- corrupted `rootfs.img`

Recovery:

1. Verify SHA256 checksums.
2. Reflash `boot.img` and `rootfs.img`.
3. Boot again with UART connected.

---

# RootFS Recovery

If the kernel starts but Ubuntu never reaches a login prompt:

```bash
lsblk
mount
df -h
```

Confirm that the expected root partition is mounted.

Reflash if necessary:

- `rootfs.img`
- `userdata.img`

Never overwrite only random partitions.

---

# Flash Recovery

If flashing fails:

- verify USB cable
- verify Rockchip loader mode
- verify image checksums
- flash the complete release directory

Check:

```text
boot.img
rootfs.img
userdata.img
env.img
idblock.img
uboot.img
```

---

# Build Failures

Useful commands:

```bash
git status
git log --oneline -5
./scripts/build-all.sh
```

Verify:

- disk space
- executable permissions
- correct Ubuntu version
- complete SDK checkout

---

# Memory / OOM Diagnostics

Search for OOM events:

```bash
dmesg | grep -i -E 'oom|killed process'
```

Check memory:

```bash
free -h
swapon --show
vmstat 1
ps aux --sort=-rss | head
```

Typical causes:

- swap disabled
- large package installation
- too many concurrent services

---

# SD Card Diagnostics

Inspect storage:

```bash
lsblk
blkid
df -h
```

Verify filesystem:

```bash
sudo fsck.ext4 /dev/mmcblk1p6
```

Signs of failure:

- I/O errors
- read-only remount
- corrupted ext4 journal

---

# Collecting Logs

Before opening a GitHub issue collect:

```bash
uname -a
cat /etc/os-release
free -h
swapon --show
lsblk
df -h
mount
ip address
ip route
systemctl --failed
journalctl -b
dmesg
```

Save everything:

```bash
mkdir diagnostics

uname -a > diagnostics/uname.txt
journalctl -b > diagnostics/journal.txt
dmesg > diagnostics/dmesg.txt
free -h > diagnostics/memory.txt
```

---

# GitHub Issue Checklist

Include:

- Board model
- Ubuntu release version
- Commit ID
- SD card model
- UART log
- dmesg
- journalctl output
- Steps to reproduce
- Photos if hardware related

---

# Recovery Procedures

## No UART

- Check power
- Check UART2
- Check adapter
- Reflash bootloader

## Login Missing

- Check rootfs
- Check systemd
- Check OOM
- Verify swap

## SSH Fails

- Ping
- Port 22
- `systemctl status ssh`
- `journalctl -u ssh`

## Package Installation Fails

- Verify swap
- Stop unnecessary services
- Retry one package at a time

---

# Engineering Notes

## Always identify the highest working layer

Power → BootROM → U-Boot → Kernel → systemd → Network → SSH → User

Never debug layers above the first failing component.

## Preserve evidence

Do not reboot immediately after a failure. Collect UART output, kernel messages and service logs first.

---

## Continue Reading

This concludes the first edition of the troubleshooting guide. Future revisions can add hardware-specific diagnostics, performance profiling and advanced recovery scenarios.
