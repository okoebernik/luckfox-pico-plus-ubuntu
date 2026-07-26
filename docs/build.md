# Build Guide

## Requirements

-   Ubuntu 22.04 under WSL2
-   Luckfox SDK
-   qemu-user-static
-   debootstrap

## Build

``` bash
./scripts/setup-wsl.sh
./scripts/clone-sdk.sh
./scripts/build-all.sh
```

The generated firmware will be available in `output/release/`.
