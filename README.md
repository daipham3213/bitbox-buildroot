# BitBox Buildroot Image

This repository contains an out‑of‑tree [Buildroot](https://buildroot.org/) setup that produces a minimal, Unicode‑capable i686 initramfs image intended to run inside the [v86 browser emulator](https://github.com/copy/v86). It packages a custom Linux kernel, BusyBox, a curated userland (Lua, curl, telnet, ncurses, dnsmasq, iputils, tinyssh, editors, etc.) and an overlayed root filesystem.

The active project name is `bitbox` (controlled by the `ACTIVE_PROJECT` make variable) and all customizations live outside the vanilla Buildroot source tree using the *br2-external* mechanism.

## Key Features

* Clean out‑of‑tree layout (source stays pristine under `buildroot/`).
* Single top‑level `Makefile` with friendly targets (`make help`).
* Pinned Buildroot version (2024.05.2) fetched by `make bootstrap`.
* External toolchain: Bootlin i686 glibc (fast builds, full locale with `C.UTF-8`).
* Initramfs root filesystem with overlay (`board/bitbox/rootfs_overlay`).
* Host sharing via 9p virtio mount (`host9p` -> `/home`).
* Virtio + legacy devices enabled: console, net, block (fd/floppy, hda/hdb, cdrom), random, vsock.
* Unicode + locale whitelist (size‑optimized, only `C` + `C.UTF-8`).
* Easy config editing & saving for Buildroot, Linux, BusyBox.
* Dynamic (auto‑generated) per‑package build targets when custom packages are added under `package/` (none yet).

## Quick Start (Windows PowerShell or POSIX shell)

```bash
# 1. Fetch and unpack Buildroot (once)
make bootstrap

# 2. Initialize configuration from defconfig
make buildroot-defconfig

# 3. Build everything (kernel + rootfs initramfs)
make all

# Optional: view available targets
make help
```

Resulting artifacts will appear under `build/bitbox/images/` (e.g. `bzImage`, `rootfs.cpio`, `rootfs.tar`). These can be wired into a v86 config (outside scope of this repo).

## Editing Configurations

Open menus:

```bash
make buildroot-menuconfig   # Buildroot packages & global settings
make linux-menuconfig       # Linux kernel
make busybox-menuconfig     # BusyBox applets
```

Persist changes back to the repository:

```bash
make buildroot-saveconfig   # Updates configs/bitbox_defconfig
make linux-saveconfig       # Copies kernel defconfig to board/bitbox/linux.conf
make busybox-saveconfig     # Copies BusyBox config to board/bitbox/busybox.conf
```

## Customization Guide

| Area | File/Dir | Purpose |
|------|----------|---------|
| Buildroot base packages | `configs/bitbox_defconfig` | Primary defconfig (toolchain, packages, overlay paths). |
| Kernel config | `board/bitbox/linux.conf` | Minimal virtio + 9p + ext2/3, tuned for v86 i686. |
| BusyBox config | `board/bitbox/busybox.conf` | Applet selection and shell behavior (ash, Unicode). |
| RootFS overlay | `board/bitbox/rootfs_overlay/` | Files merged into initramfs (init script, motd, profile scripts, etc.). |
| Users table | `board/bitbox/users` | Custom users/groups added at build time. |
| Locale | Defined in `bitbox_defconfig` | Whitelist for size reduction while keeping UTF‑8. |

Overlay notable files:

* `init` – mounts `devtmpfs` and hands off to `/sbin/init` with UTF‑8 locale.
* `etc/inittab` – spawns shells on `console`, `tty2–tty4`, and a shell on `ttyS0`.
* `etc/fstab` – includes a 9p mount (`host9p`) for host<->guest sharing under `/home`.
* `etc/profile.d/mount-9p.sh` – convenience remount (requires `sudo`).
* `etc/profile.d/startup.sh` – ensures helper binaries executable & starts DHCP client (`udhcpc`).

## Adding Packages

To add custom external packages:
1. Create directory `package/<pkgname>/` with `<pkgname>.mk` and `Config.in` as per Buildroot guidelines.
2. Include the new `Config.in` from the top-level (empty) `Config.in` if needed for menu organization.
3. Run `make buildroot-menuconfig` to enable it, then `make buildroot-saveconfig`.
4. Use dynamic targets `make buildroot-<pkgname>-build`, `-rebuild`, `-clean`, `-dirclean`.

Currently there are no custom external packages; the dynamic targets system is ready for future expansion.

## Switching Projects (Future)

`ACTIVE_PROJECT` defaults to `bitbox`. If additional boards/projects are added, provide matching:

* `configs/<name>_defconfig`
* `board/<name>/...` (kernel + BusyBox configs, overlay)

Then build using:

```powershell
make ACTIVE_PROJECT=<name> buildroot-defconfig
make ACTIVE_PROJECT=<name> all
```

## Cleaning & Rebuilding

```bash
make clean        # Remove build artifacts (keeps downloads)
make dirclean     # Full distclean (also removes downloads)
make rebuild      # dirclean + defconfig + full build
```

## Release Archive

Create a compressed bundle (renames bzImage) by setting a version:

```bash
RELEASE_VER=1.0.0 make release
```

Output: `v86-buildroot-<ver>.tar.bz2` containing kernel image + rootfs.

## Directory Layout (after `make buildroot-defconfig`)

```
bitbox-buildroot
├── board/
│   └── bitbox/
│       ├── busybox.conf        # BusyBox configuration (saved via busybox-saveconfig)
│       ├── linux.conf          # Kernel configuration (saved via linux-saveconfig)
│       ├── users               # Users table
│       └── rootfs_overlay/     # Overlay root
│           ├── init
│           └── etc/ ...
├── build/bitbox/               # Build output (O=...) incl. images/
├── buildroot/                  # Untouched Buildroot source tree
├── configs/
│   └── bitbox_defconfig        # Buildroot defconfig
├── external.desc               # br2-external metadata
├── external.mk                 # br2-external (empty stub)
├── Config.in                   # br2-external top-level (currently empty)
├── LICENSE
├── Makefile
└── README.md
```

## Troubleshooting Tips

* Missing `buildroot/`: run `make bootstrap` first.
* Config changes not sticking: run corresponding `*-saveconfig` target.
* Locale issues / garbled characters: ensure `C.UTF-8` is selected; check `LANG` export in overlay `init`.
* 9p mount not present: verify kernel 9p options enabled and `host9p` device provided by emulator; run `sudo mount -t 9p host9p /home`.
* Networking: DHCP started in `startup.sh` (`udhcpc &`). Use `ifconfig -a` or `ip addr` to inspect.

## License

See `LICENSE` for details.

## References & Further Reading

* [Buildroot Manual](https://buildroot.org/downloads/manual/manual.html)
* [Out-of-Tree Customizations](https://buildroot.org/downloads/manual/manual.html#outside-br-custom)
* [Setting up Out-of-Tree Folder Structure](https://eerdemsimsek.medium.com/setting-up-buildroot-out-of-tree-folder-structure-for-raspberry-pi-4b-fbd9765c0206)
* [v86 Emulator](https://github.com/copy/v86)
* [Original v86 Buildroot Issue / Discussion](https://github.com/copy/v86/issues/725)
