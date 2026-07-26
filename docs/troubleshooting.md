# Troubleshooting Guide

> **Luckfox Pico Plus Ubuntu**\
> Complete Engineering Handbook

------------------------------------------------------------------------

## Contents

1.  Part 1 -- Diagnostic Fundamentals
2.  Part 2 -- Linux System Diagnostics
3.  Part 3 -- Engineering Handbook

------------------------------------------------------------------------

# Troubleshooting Guide --- Part 1

> **Luckfox Pico Plus Ubuntu**
>
> Engineering Handbook

------------------------------------------------------------------------

# Table of Contents

1.  Introduction
2.  Diagnostic Philosophy
3.  Troubleshooting Workflow
4.  Boot Architecture
5.  Boot Problems
6.  UART Diagnostics
7.  Flash Problems
8.  RootFS Recovery
9.  Kernel Panic
10. Recovery Basics

------------------------------------------------------------------------

# 1. Introduction

This guide provides a structured troubleshooting methodology for Ubuntu
running on the Luckfox Pico Plus.

Unlike traditional "try this" troubleshooting, every chapter follows the
same engineering process:

1.  Observe
2.  Collect Evidence
3.  Identify the failing layer
4.  Apply exactly one corrective action
5.  Verify the result

![](docs/images/luckfox-troubleshooting-overview.svg)

------------------------------------------------------------------------

# 2. Diagnostic Philosophy

## Core Rule

Always determine **the first component that fails**.

Never start debugging SSH if Linux has not booted.

Never repair a filesystem before confirming that the storage itself is
healthy.

Never reflash before preserving UART output.

### Preserve Evidence

Collect:

-   Complete UART log
-   Release version
-   SHA256 verification
-   Board model
-   Memory status
-   Storage status

![](docs/images/luckfox-diagnostic-workflow.svg)

------------------------------------------------------------------------

# 3. Boot Architecture

Boot sequence:

``` text
Power
 ↓
BootROM
 ↓
idblock.img
 ↓
U-Boot
 ↓
boot.img
 ↓
Linux Kernel
 ↓
RootFS
 ↓
systemd
 ↓
Login
```

Each layer depends on the previous one.

------------------------------------------------------------------------

# 4. Boot Problems

Typical symptoms:

-   No LEDs
-   No UART output
-   Boot loop
-   Stops at U-Boot
-   Stops at "Starting kernel..."
-   Kernel panic
-   Login prompt never appears

Follow the decision tree before changing configuration.

![](docs/images/luckfox-boot-decision-tree.svg)

Checklist:

-   Verify power supply
-   Verify UART wiring
-   Verify image versions
-   Verify SHA256SUMS
-   Capture UART log

------------------------------------------------------------------------

# 5. UART Diagnostics

UART is the primary diagnostic interface.

Configuration:

-   115200 Baud
-   8 Data Bits
-   No Parity
-   1 Stop Bit

Expected milestones:

-   BootROM
-   U-Boot banner
-   Linux Kernel
-   systemd
-   Login

Missing output indicates the layer immediately before it failed.

------------------------------------------------------------------------

# 6. Flash Problems

Common causes:

-   Wrong release
-   Missing image
-   Corrupted SD card
-   Interrupted write
-   Invalid SHA256

Recovery order:

1.  Verify release directory
2.  Verify checksums
3.  Rewrite SD card
4.  Capture UART

![](docs/images/luckfox-flash-recovery.svg)

------------------------------------------------------------------------

# 7. RootFS Recovery

Typical symptoms:

-   Kernel panic
-   Read-only filesystem
-   ext4 errors

Procedure:

``` bash
lsblk -f
findmnt /
df -h
dmesg | grep -Ei "ext4|mmc|i/o"
```

Only run `fsck.ext4` on an **unmounted** filesystem.

![](docs/images/luckfox-rootfs-recovery.svg)

------------------------------------------------------------------------

# 8. Kernel Panic

Kernel panics should always be analyzed from the **first error**, not
the final line.

Typical causes:

-   Wrong Device Tree
-   Invalid root=
-   Corrupted RootFS
-   Incompatible kernel

Useful commands:

``` bash
cat /proc/cmdline
sha256sum -c SHA256SUMS
lsblk -f
```

![](docs/images/luckfox-kernel-panic-diagnosis.svg)

------------------------------------------------------------------------

# 9. Recovery Basics

Always work in this order:

1.  Preserve logs
2.  Verify images
3.  Verify storage
4.  Apply one change
5.  Reboot
6.  Compare results

------------------------------------------------------------------------

# Quick Reference

![](docs/images/luckfox-troubleshooting-quick-reference.svg)

## Next Part

Part 2 covers:

-   systemd
-   Memory
-   Swap
-   OOM Killer
-   Network
-   SSH
-   Storage
-   Performance
-   Maintenance

------------------------------------------------------------------------

# Troubleshooting Guide --- Part 2

> **Luckfox Pico Plus Ubuntu**\
> Linux System Diagnostics

------------------------------------------------------------------------

# Table of Contents

1.  systemd Diagnostics
2.  Memory Management
3.  Swap Configuration
4.  OOM Killer
5.  Network Diagnostics
6.  SSH Troubleshooting
7.  Storage Diagnostics
8.  Performance Analysis
9.  Maintenance Procedures
10. Operational Checklist

------------------------------------------------------------------------

# 1. systemd Diagnostics

The majority of userspace problems can be traced back to one or more
failed systemd units.

![](docs/images/luckfox-systemd-diagnostics.svg)

## First checks

``` bash
systemctl --failed
systemctl status <service>
journalctl -u <service> -b
```

Look for:

-   Failed dependencies
-   Missing mount points
-   Permission problems
-   Configuration errors
-   Out-of-memory events

Engineering note:

> Always investigate the **first failed service**. Later failures are
> often only consequences.

------------------------------------------------------------------------

# 2. Memory Management

Ubuntu on the Luckfox Pico Plus has limited RAM. Efficient memory usage
is essential.

![](docs/images/luckfox-memory-oom-diagnostics.svg)

Useful commands:

``` bash
free -h
vmstat 1
cat /proc/meminfo
```

Monitor:

-   Available memory
-   Cached memory
-   Swap usage
-   Page faults

Warning signs:

-   Constant swapping
-   Services restarting
-   SSH disconnects
-   Slow package installation

------------------------------------------------------------------------

# 3. Swap Configuration

Verify swap:

``` bash
swapon --show
free -h
```

Expected result:

-   Swap device active
-   Approximately 512 MiB (depending on release)
-   Automatically enabled after boot

If swap is missing:

-   Check `/etc/fstab`
-   Verify swapfile existence
-   Enable manually:

``` bash
sudo swapon -a
```

------------------------------------------------------------------------

# 4. OOM Killer

The Linux Out-Of-Memory Killer terminates processes when RAM is
exhausted.

Diagnosis:

``` bash
dmesg | grep -Ei "oom|killed"
journalctl -k
```

Typical victims:

-   sshd child processes
-   apt
-   Python applications
-   Build processes

Recovery strategy:

1.  Enable swap
2.  Stop unnecessary services
3.  Retry workload
4.  Verify stability

------------------------------------------------------------------------

# 5. Network Diagnostics

![](docs/images/luckfox-network-diagnostics.svg)

Basic workflow:

``` bash
ip -br address
ip route
ping <gateway>
ping 8.8.8.8
getent hosts github.com
```

Troubleshoot in layers:

1.  Physical link
2.  IP address
3.  Default route
4.  DNS
5.  Remote service

Never assume DNS is working simply because an IP address exists.

------------------------------------------------------------------------

# 6. SSH Troubleshooting

![](docs/images/luckfox-ssh-troubleshooting.svg)

Useful commands:

``` bash
ss -ltn
systemctl status ssh
journalctl -u ssh -b
ssh -vvv user@board
```

Common causes:

-   SSH service stopped
-   Firewall rules
-   Wrong credentials
-   PAM configuration
-   Memory pressure

------------------------------------------------------------------------

# 7. Storage Diagnostics

![](docs/images/luckfox-sd-card-diagnostics.svg)

Verify storage:

``` bash
lsblk -f
findmnt /
df -h
df -i
```

Kernel log:

``` bash
dmesg | grep -Ei "mmc|ext4|i/o"
```

Repeated I/O errors usually indicate failing media.

------------------------------------------------------------------------

# 8. Performance Analysis

Measure system load:

``` bash
uptime
top
vmstat 1
iostat
```

Look for:

-   CPU saturation
-   High I/O wait
-   Swap activity
-   Large resident processes

Performance tuning should always be based on measurements---not
assumptions.

------------------------------------------------------------------------

# 9. Maintenance Procedures

![](docs/images/luckfox-maintenance-workflow.svg)

Recommended workflow:

1.  Backup
2.  Record baseline
3.  Apply one change
4.  Reboot with UART connected
5.  Verify all services
6.  Document results

Avoid combining multiple major changes in a single maintenance window.

------------------------------------------------------------------------

# 10. Operational Checklist

Before considering a system healthy verify:

-   [ ] No failed systemd services
-   [ ] Swap active
-   [ ] No OOM events
-   [ ] Network operational
-   [ ] SSH stable
-   [ ] Storage healthy
-   [ ] UART boot without errors

------------------------------------------------------------------------

# Next Part

Part 3 completes the handbook with:

-   Build Diagnostics
-   Release Verification
-   GitHub Issue Workflow
-   Recovery Checklists
-   Troubleshooting Matrix
-   Engineering Best Practices
-   Complete Command Reference

------------------------------------------------------------------------

# Troubleshooting Guide --- Part 3

> **Luckfox Pico Plus Ubuntu**\
> Engineering Handbook & Best Practices

------------------------------------------------------------------------

# Table of Contents

1.  Build Diagnostics
2.  Release Verification
3.  GitHub Issue Workflow
4.  Engineering Best Practices
5.  Recovery Checklist
6.  Troubleshooting Matrix
7.  Command Reference
8.  Appendix

------------------------------------------------------------------------

# 1. Build Diagnostics

Build failures are usually caused by environment inconsistencies rather
than source code defects.

![](docs/images/luckfox-build-diagnostics.svg)

## Verify the build host

``` bash
cat /etc/os-release
df -h .
date
git status
```

## Verify release artifacts

``` bash
find output/release -maxdepth 1 -type f
sha256sum -c output/release/SHA256SUMS
```

Engineering rule:

-   Investigate the **first** build error.
-   Ignore cascading errors until the root cause is resolved.

------------------------------------------------------------------------

# 2. Release Verification

Before flashing, verify:

  Item      Check
  --------- --------------------
  Board     Correct target
  Release   Expected version
  SHA256    All files verified
  Images    Complete
  SD Card   Healthy

Mandatory files:

-   download.bin
-   idblock.img
-   uboot.img
-   env.img
-   boot.img
-   userdata.img
-   rootfs.img

Never flash a release with missing images.

------------------------------------------------------------------------

# 3. GitHub Issue Workflow

![](docs/images/luckfox-github-issue-workflow.svg)

A useful issue contains:

## Environment

-   Board revision
-   Ubuntu release
-   Repository version
-   Commit hash

## Reproduction

-   Exact steps
-   Expected result
-   Actual result

## Diagnostics

Attach:

-   UART log
-   dmesg
-   journalctl -b
-   free -h
-   swapon --show
-   lsblk -f

Logs should be attached as **text**, not screenshots.

------------------------------------------------------------------------

# 4. Engineering Best Practices

## One Change Rule

Only modify **one variable at a time**.

Bad:

-   Update packages
-   Replace kernel
-   Change configuration
-   Enable new service

all at once.

Good:

1.  Apply one change
2.  Reboot
3.  Test
4.  Document
5.  Continue

------------------------------------------------------------------------

## Preserve Evidence

Before rebooting:

-   Save UART log
-   Save journal
-   Save dmesg
-   Save configuration

------------------------------------------------------------------------

## Recovery Strategy

Preferred order:

1.  Observe
2.  Collect
3.  Diagnose
4.  Repair
5.  Verify

Avoid unnecessary reflashing.

------------------------------------------------------------------------

# 5. Recovery Checklist

Before declaring recovery successful verify:

-   [ ] Boot without UART errors
-   [ ] Login prompt available
-   [ ] Swap enabled
-   [ ] No failed systemd units
-   [ ] No kernel panic
-   [ ] No ext4 errors
-   [ ] Network operational
-   [ ] SSH stable
-   [ ] Storage healthy

------------------------------------------------------------------------

# 6. Troubleshooting Matrix

  Symptom                Likely Layer        First Action
  ---------------------- ------------------- ----------------------------
  No LEDs                Power               Verify supply
  No UART                BootROM             Verify serial wiring
  Stops at U-Boot        Bootloader          Verify images
  Kernel panic           Kernel              Inspect cmdline and RootFS
  Login missing          systemd             Check failed units
  SSH disconnects        Memory              Verify swap and OOM
  Read-only filesystem   Storage             Inspect ext4 and SD card
  Random crashes         Hardware / Memory   Review UART and dmesg

------------------------------------------------------------------------

# 7. Command Reference

## Boot

``` bash
cat /proc/cmdline
lsblk -f
findmnt /
```

## Memory

``` bash
free -h
swapon --show
vmstat 1
```

## Services

``` bash
systemctl --failed
systemctl status ssh
journalctl -b
```

## Network

``` bash
ip -br address
ip route
ss -ltn
```

## Storage

``` bash
df -h
df -i
dmesg | grep -Ei "mmc|ext4|i/o"
```

------------------------------------------------------------------------

# 8. Appendix

## Recommended Diagnostic Bundle

Collect the following before opening an issue:

-   Complete UART boot log
-   dmesg output
-   journalctl -b
-   free -h
-   swapon --show
-   lsblk -f
-   SHA256 verification
-   Git commit hash
-   Ubuntu release
-   Board revision

------------------------------------------------------------------------

# Final Engineering Rules

1.  Preserve evidence before changing anything.
2.  Change only one variable at a time.
3.  Verify every release before flashing.
4.  Use UART as the primary diagnostic interface.
5.  Prefer root-cause analysis over repeated reflashing.
6.  Document successful recoveries for future reference.

------------------------------------------------------------------------

# What's Next?

Merge **Part 1**, **Part 2**, and **Part 3** into a single comprehensive
`troubleshooting.md` with:

-   Unified table of contents
-   Cross-references
-   Embedded SVGs
-   Consistent callout boxes
-   Shared navigation
-   Professional formatting matching the rest of the documentation
