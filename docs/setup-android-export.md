# Godot Android Export Dependencies Setup

To export Godot projects to Android for **Meta Quest 3S**, you need to set up the following dependencies:

## 1. Install Java Development Kit (JDK)
- Godot 4.x requires **JDK 17**.
- On Ubuntu:
  ```sh
  sudo apt update
  sudo apt install openjdk-17-jdk
  ```

## 2. Install Android SDK & Command Line Tools
- Download the [Android Command Line Tools](https://developer.android.com/studio#command-tools).
- Extract and place them in a directory, e.g., `~/Android/cmdline-tools`.
- Add to your PATH:
  ```sh
  export PATH="$PATH:$HOME/Android/cmdline-tools/bin"
  ```

## 3. Install Android Build Tools & Platforms
- Run the following to install required packages:
  ```sh
  sdkmanager --sdk_root=$HOME/Android "platform-tools" "platforms;android-33" "build-tools;33.0.2"
  ```

## 4. Accept Licenses
- Accept all licenses:
  ```sh
  yes | sdkmanager --licenses
  ```

## 5. Download Godot Android Export Templates
- In Godot: `Editor > Manage Export Templates` and download the Android templates.

## 6. Configure Godot Android Export Preset
- In Godot: `Project > Export > Add... > Android`.
- Set the paths for JDK and Android SDK if not auto-detected.

## 7. (Optional) Enable USB Debugging on Meta Quest 3S
- Enable Developer Mode in the Meta Quest app.
- Connect your headset via USB and allow debugging.

---

**Troubleshooting:**
- If Godot cannot find the SDK/JDK, set the paths manually in `Editor Settings > Export > Android`.
- Ensure your user owns the Android SDK directory.

---

**References:**
- [Godot Docs: Exporting for Android](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html)
- [Meta Quest Developer Setup](https://developer.oculus.com/documentation/native/android/mobile-device-setup/)
