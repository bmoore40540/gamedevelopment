# Export and Install APK on Meta Quest 3S

Follow these steps to export your Godot project as an APK and install it on your Meta Quest 3S:

## 1. Prepare Your Project
- Open your project in Godot (in the `godot/` folder).
- Ensure the OpenXR plugin is enabled (`Project > Project Settings > Plugins`).
- Make sure your main scene is set (`Project > Project Settings > Application > Run > Main Scene`).

## 2. Configure Android Export Preset
- Go to `Project > Export` and add an **Android** preset.
- Set the package name (e.g., `com.yourcompany.vrproject`).
- Set the version code and version name.
- Ensure the paths for JDK and Android SDK are set in `Editor > Editor Settings > Export > Android`.
- (Optional) Set the icon and permissions as needed.

## 3. Export the APK
- In the Export dialog, click **Export Project** and choose a location (e.g., `../builds/vrproject.apk`).
- If prompted, download and install the Android export templates.

## 4. Enable Developer Mode on Meta Quest 3S
- In the Meta Quest mobile app, enable **Developer Mode** for your headset.
- Reboot the headset if needed.

## 5. Connect Meta Quest 3S to PC
- Connect your Meta Quest 3S via USB.
- Put on the headset and allow USB debugging if prompted.

## 6. Install APK via ADB
- On your PC, run:
  ```sh
  adb install -r ../builds/vrproject.apk
  ```
- If `adb` is not installed, install it with:
  ```sh
  sudo apt install adb
  ```

## 7. Launch the App
- In the Quest headset, go to **Apps > Unknown Sources** and launch your app.

---

**Troubleshooting:**
- If the app doesn't appear, make sure the APK is signed (Godot signs debug builds by default).
- Check for errors in Godot's export dialog.
- Ensure the Meta Quest 3S is in Developer Mode and USB debugging is allowed.

---

**References:**
- [Godot Docs: Exporting for Android](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html)
- [Meta Quest Developer Setup](https://developer.oculus.com/documentation/native/android/mobile-device-setup/)
