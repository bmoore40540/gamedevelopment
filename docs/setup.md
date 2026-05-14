# Setup Guide: Godot + OpenXR for Meta Quest 3S

This guide gets you from a fresh machine to a first runnable VR build on Meta Quest 3S.

## 1. Install Required Tools

Install the following:

- Godot 4.x (standard build)
- Android SDK + platform tools (for adb)
- JDK 17 or newer
- Android build-tools (via Android SDK Manager)

On Ubuntu, you can install adb quickly with:

```sh
sudo apt update && sudo apt install -y adb
```

## 2. Open the Project

1. Launch Godot.
2. Import the project at `godot/`.
3. Let Godot generate/update `godot/project.godot` for your version.

## 3. Enable XR

1. Open `Project > Project Settings`.
2. Enable OpenXR plugin support.
3. Set your main XR scene under `Application > Run > Main Scene`.

### Quest-friendly rendering defaults (recommended)

In `Project Settings`, these defaults are a good starting point for Meta Quest 3S performance:

- Use the **Mobile** renderer (Forward Mobile), not Forward+.
- Keep MSAA modest (often **2x**) and avoid expensive post-processing (SSAO, glow, volumetrics) unless required.
- Prefer **no real-time shadows** in early prototypes; add them later only if you can afford the cost.

## 4. Configure Android Export

1. Open `Project > Export`.
2. Add an Android preset.
3. Set package name, version code, and version name.
4. In `Editor > Editor Settings > Export > Android`, set SDK/JDK paths.
5. Install export templates if prompted.

## 5. Prepare the Headset

1. Enable Developer Mode for your Meta Quest 3S in the Meta mobile app.
2. Connect headset via USB.
3. Accept USB debugging prompt in-headset.

Verify connection:

```sh
adb devices
```

## 6. Export and Install

1. Export APK to `builds/` (example: `builds/first-test.apk`).
2. Install to device:

```sh
adb install -r builds/first-test.apk
```

3. In headset, launch from `Apps > Unknown Sources`.

## 7. First Validation Checklist

- App launches on Meta Quest 3S
- Headset tracking updates correctly
- Both controllers are detected
- Basic room renders with stable frame timing
- Simple grab interaction works

## References

- Godot Android export docs: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html
- Meta device setup: https://developer.oculus.com/documentation/native/android/mobile-device-setup/
