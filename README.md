# AgriShield

AgriShield is organized as a product workspace with separate areas for the mobile app and hardware firmware.

## Folder Structure

```text
AgriShield/
  apps/
    mobile/        Flutter mobile application
  hardware/
    firmware/      ESP32 / sensor firmware workspace
```

## Mobile App

The Flutter app lives in `apps/mobile`.

```powershell
cd apps/mobile
flutter pub get
flutter run
```

## Hardware

Hardware firmware work belongs under `hardware`.

- Put ESP32 firmware projects in `hardware/firmware`.

