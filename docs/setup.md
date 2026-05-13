# Setup (Godot + Meta Quest 3S)

This repo targets **Meta Quest 3S** using **Godot 4 + OpenXR** (Android export).

## Prereqs

- **Godot 4.x** installed on your dev machine
- **Android SDK + platform tools** (includes `adb`)
- **JDK 17** (required by recent Android builds)
- Meta Quest headset in **Developer Mode** with **USB debugging** enabled

## Godot: enable OpenXR

1. Open the project in Godot (folder: `godot/`).
2. Enable **OpenXR** in `Project > Project Settings > Plugins` (or the equivalent OpenXR toggle in your Godot version).
3. Run the project on desktop first to verify the scene loads.

## Android export setup

1. In Godot, open `Editor > Editor Settings > Export > Android`.
2. Set paths for:
   - Android SDK
   - Java/JDK
   - Debug keystore (or generate one via Godot)
3. Install Godot Android export templates for your Godot version.

## Export to Quest

1. Connect the headset via USB.
2. Verify the device is visible:
   - `adb devices`
3. In Godot: `Project > Export...`
4. Choose the **Android** preset and export an `.apk`.
5. Install:
   - `adb install -r path/to/your.apk`

## Common gotchas

- If the headset is not listed in `adb devices`, confirm Developer Mode and USB debugging are enabled and re-plug the cable.
- If export fails, double-check the Android SDK + JDK paths in Godot editor settings.

