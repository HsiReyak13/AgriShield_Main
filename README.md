# AgriShield

AgriShield is organized as a product workspace with separate areas for the mobile app, hardware work, project documentation, and BMAD planning artifacts.

## Folder Structure

```text
AgriShield/
  apps/
    mobile/        Flutter mobile application
  hardware/
    firmware/      ESP32 / sensor firmware workspace
    docs/          Hardware setup notes, wiring notes, and device references
  docs/            Shared project documentation
  design-artifacts/
  _bmad/
  _bmad-output/
```

## Mobile App

The Flutter app lives in `apps/mobile`.

```powershell
cd apps/mobile
flutter pub get
flutter run
```

## Hardware

Hardware and firmware work belongs under `hardware`.

- Put ESP32 firmware projects in `hardware/firmware`.
- Put wiring diagrams, setup notes, sensor notes, and device references in `hardware/docs`.
