# MSI Thin 15 B13VE – macOS Tahoe (OpenCore) with Intel iGPU acceleration at 144 Hz + RTX on demand

| Part | Model |
|---|---|
| Laptop | MSI Thin 15 B13VE (MS-16R8) |
| CPU | Intel Core i7-13620H (Raptor Lake-H, 6P+4E) |
| iGPU | Intel UHD Graphics 8086:A7A8 rev 04 (64 EU), drives the 1920×1080 144 Hz panel (no MUX) |
| dGPU | NVIDIA RTX 4050 Laptop 6 GB |
| macOS | Tahoe 26.7.3 (25G342), SMBIOS MacBookPro16,2 |

## What works
- **Intel iGPU acceleration (Metal) on the built-in panel at 144 Hz**: WhateverXe (jkbuha contrib branch, `-wex-edp-keep`) with two fixes of my own, in `patches/`
- **RTX 4050 for apps and games** (hybrid mode, HighDelay/NullMoth NVIDIA driver) while the iGPU keeps the desktop
- Full CPU turbo (CPUFriend + CpuTopologyRebuild), audio (SimpleHDA + AppleALC), Wi-Fi (itlwm), Bluetooth, keyboard, trackpad
- OpenCanopy boot picker (GoldenGate)

## Not working / untested
- **Sleep: disabled** (`pmset -a sleep 0 displaysleep 0 disablesleep 1`). Shut down instead.
- RTX idle power-off (`nvrtd3`) not verified yet; HDMI, brightness keys and external displays not tested

## Three modes (copy the one you want over `config.plist`)
| File | Desktop on | RTX |
|---|---|---|
| `config.plist` (default) | Intel iGPU, 144 Hz | on demand for apps/games |
| `config-wex.plist` | Intel iGPU, 144 Hz | off |
| `config-main.plist` | RTX (frames copied to the Intel panel) | always on |

## Before you use it
1. **Generate your own SMBIOS** (MacBookPro16,2) with GenSMBIOS and fill in `PlatformInfo → Generic` (serial, MLB, ROM, SystemUUID). The fields are blank here.
2. Wi-Fi: replace `YOUR_WIFI_NAME` / `YOUR_WIFI_PASSWORD` in `Kexts/itlwm.kext/Contents/Info.plist`, or use HeliPort.
3. Inside macOS install **WhateverXe Graphics 0.4.4** (`.pkg`, from b00t0x/WhateverXe-Graphics) and the **HighDelay NVIDIA driver 3.0.2-nvk**.
4. BIOS DVMT on this laptop is 60 MB, hence `-igfxdvmt` + `framebuffer-stolenmem`.

## My WhateverXe fixes (`patches/whateverxe-msi-rplp-144hz.patch`)
1. **MSI VBT**: the VBT lists a second child device on DDI A next to the eDP panel. WhateverXe rejected the whole VBT as a conflict; now an eDP record wins over a later duplicate on its port (as Linux i915 does).
2. **144 Hz**: the watermark clock check allowed only 1 pixel per CDCLK cycle. Display version 13 does 2 pixels per clock (as i915), so the 342 MHz 144 Hz mode fits the firmware's 179.2 MHz CDCLK.

Built from https://github.com/jkbuha/WhateverXe-contrib (branch `contrib/xps-mobile-xelp`, WhateverXe 0.8.3) with the patch applied.

## Credits
acidanthera (OpenCore, Lilu, VirtualSMC, AppleALC), b00t0x (WhateverXe, WhateverXe Graphics, AMFIAnchor, CpuTopologyRebuild), jkbuha (eDP keep), HighDelay/NullMoth (NVIDIA driver), OpenIntelWireless (itlwm, IntelBluetoothFirmware), laobamac (SimpleHDA), ductruongvu23 (i7-13620H CPUFriend profile), VoodooI2C. WhateverXe is licensed as in `WhateverXe-LICENSE.txt`.
