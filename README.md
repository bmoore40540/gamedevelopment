# Meta Quest 3S Game Development

Starter repository for building a **Meta Quest 3S** game using **Godot 4 + OpenXR**.

## Stack

- **Engine:** Godot 4.x
- **XR runtime:** OpenXR
- **Platform target:** Android / Meta Quest 3S
- **Scripting:** GDScript

## Goals

- Keep the repo simple and organized
- Build directly for standalone Quest hardware
- Start with a minimal VR prototype
- Document setup and milestones clearly

## Recommended repository layout

```text
.
├── README.md
├── .gitignore
├── docs/
│   ├── setup.md
│   └── roadmap.md
├── godot/
│   ├── README.md
│   ├── project.godot
│   ├── scenes/
│   ├── scripts/
│   └── addons/
├── assets/
│   ├── art/
│   ├── audio/
│   └── models/
└── builds/
```

## First milestones

- [ ] Set up Godot Android export dependencies
- [ ] Create a Godot project with OpenXR enabled
- [ ] Add a basic VR scene
- [ ] Verify headset tracking and controller input
- [ ] Export and install first APK on Meta Quest 3S

## Suggested first prototype

A simple room-scale VR scene with:
- floor
- lighting
- left/right controller tracking
- basic grab interaction
- one interactable cube

## Next steps

1. Follow `docs/setup.md`
2. Open the Godot project in `godot/`
3. Enable OpenXR and Android export
4. Build a test APK
5. Iterate on the first VR interaction loop
