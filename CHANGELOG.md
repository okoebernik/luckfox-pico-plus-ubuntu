# Changelog

All notable changes to this project will be documented in this file.

The format is based on **Keep a Changelog** and follows
**Semantic Versioning (SemVer)**.

---

## [0.1.0] - 2026-07-27

### 🎉 Initial Public Release

This is the first official release of **Ubuntu 22.04 for the Luckfox Pico Plus**.

The project now provides a reproducible Ubuntu-based firmware image together
with a complete build pipeline, extensive documentation and engineering
guidelines.

---

## ✨ Added

### Ubuntu Platform

- Ubuntu 22.04 RootFS
- Complete bootable firmware image
- Ethernet networking
- SSH support
- Swap support
- Optimized low-memory configuration
- Ubuntu package management (APT)

### Build System

- Fully reproducible build pipeline
- Automated RootFS image generation
- Firmware collection scripts
- Release packaging
- SHA256 checksum generation
- Build metadata generation
- Modular build scripts
- Release folder generation for SocToolKit

### Documentation

Created the complete documentation set:

- README
- Introduction
- Getting Started
- Build System
- Flashing
- First Boot
- Memory Optimization
- Troubleshooting
- Development
- Project Roadmap

### Visual Documentation

Added approximately **60 SVG engineering diagrams**, including:

- Build pipeline
- Boot process
- Release layout
- Flash workflow
- Memory optimization
- Troubleshooting workflow
- Development lifecycle
- Git workflow
- Testing pipeline
- Project roadmap
- Long-term vision
- Release roadmap

### Engineering

- Reproducible project structure
- Consistent documentation format
- Standardized SVG design language
- Navigation across all documentation
- YAML front matter for all Markdown documents
- Unified documentation style

---

## 🚀 Improved

- Build reproducibility
- Documentation consistency
- Navigation between documents
- Release structure
- Recovery procedures
- Development workflow
- Engineering documentation quality

---

## 📚 Documentation

The following documents reached production quality:

| Document | Status |
|----------|--------|
| README | ✅ |
| Introduction | ✅ |
| Getting Started | ✅ |
| Build System | ✅ |
| Flashing | ✅ |
| First Boot | ✅ |
| Memory Optimization | ✅ |
| Troubleshooting | ✅ |
| Development | ✅ |
| Project Roadmap | ✅ |

---

## 🛠 Build System

Implemented:

- automated RootFS optimization
- kernel module installation
- RootFS image generation
- firmware collection
- release packaging
- release verification
- checksum generation

---

## 🧪 Validation

Verified:

- Ubuntu boot
- Ethernet connectivity
- SSH access
- Swap activation
- Build pipeline
- Release packaging
- Documentation links
- SVG references
- Navigation consistency

---

## 📦 Release Artifacts

The release package contains:

- download.bin
- idblock.img
- uboot.img
- boot.img
- rootfs.img
- userdata.img
- env.img
- manifest.txt
- SHA256SUMS

---

## 📖 Project Status

Version **0.1.0** represents the first complete engineering release.

The project now provides:

- a reproducible Ubuntu distribution
- documented build procedures
- complete engineering documentation
- release verification
- troubleshooting guides
- development guidelines
- project roadmap

Future releases will focus primarily on:

- hardware enablement
- automated testing
- CI/CD
- additional documentation
- long-term maintenance

---

## ⚠ Known Limitations

Current limitations include:

- CI/CD pipeline not yet implemented
- Automated regression testing planned
- Additional hardware documentation planned
- GPIO and camera guides planned
- Community contribution workflow will evolve over future releases

---

## ❤️ Acknowledgements

This release represents the completion of the project's initial engineering
phase.

Special emphasis has been placed on:

- reproducibility
- maintainability
- transparency
- documentation quality
- engineering best practices

These principles will continue to guide future development.

---

## Version Summary

| Version | Status | Description |
|----------|--------|-------------|
| 0.1.0 | ✅ Released | Initial public release |

---
# Changelog

## [0.2.0] - Unreleased

### Added

- Added `luckfox-info` system information utility.
- Added automatic root filesystem expansion during the first boot.
- Added one-shot systemd service for first boot initialization.
- Added automatic generation of `/etc/luckfox-release`.

### Changed

- Improved `create-rootfs-image.sh` to create the swapfile directly inside the ext4 image.
- Improved `optimize-rootfs.sh` with reproducible system initialization.
- Improved first boot experience by automatically expanding the root filesystem.
- Improved image generation workflow for better reliability.

### Fixed

- Fixed swapfile creation to avoid sparse files that could not be activated by `swapon`.
- Fixed out-of-memory (OOM) condition during the first login.
- Fixed root filesystem image initialization on freshly flashed systems.

### Added

- Added `luckfox-health` for automated system health checks.
- Added checks for swap, memory, storage, persistent MAC, networking,
  release metadata and failed systemd services.
- Added machine-readable exit codes for automation and support workflows.


For upcoming changes, see the **Project Roadmap** in:

```text
docs/project-roadmap.md
```