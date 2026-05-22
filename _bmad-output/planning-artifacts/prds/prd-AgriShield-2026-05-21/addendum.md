# Addendum: AgriShield PH PRD Supporting Notes

This addendum preserves implementation-oriented context from `C:\Users\LA\Downloads\agrishield_ph_codex_context_updated.md` that is useful for architecture and development but should not dominate the PRD.

## Source Design References

- Lovable preview URL is listed in the source context as the primary mockup reference.
- ChatGPT shared design/mockup conversation is listed in the source context as a secondary reference, with the note that it may require an accessible project/browser environment.

## Suggested Core System Flow

```text
Sensors
  ->
ESP32 Microcontroller
  -> Wi-Fi
Firebase Database
  ->
Flutter Mobile Application
  ->
Dashboard + In-App Alerts + Recommendations + History
```

## Hardware Baseline

- Soil moisture sensor: SEN0193.
- Temperature and humidity sensor: DHT22.
- Microcontroller: ESP32.
- MVP testing posture: conceptual prototype and defense demonstration; real farm deployment or field validation is out of scope.

## Recommended Firebase Collections

```text
users
farms
sensor_readings
alerts
```

## Example `sensor_readings` Record

```json
{
  "id": "auto_generated_id",
  "farmId": "farm_001",
  "deviceId": "esp32_001",
  "soilMoisture": 42,
  "waterLevel": 8,
  "temperature": 34.5,
  "humidity": 70,
  "fieldStatus": "Warning",
  "recommendation": "Check field water level.",
  "source": "real",
  "createdAt": "server_timestamp"
}
```

## Example `alerts` Record

```json
{
  "id": "auto_generated_id",
  "farmId": "farm_001",
  "deviceId": "esp32_001",
  "sensor": "waterLevel",
  "severity": "Critical",
  "readingValue": 3,
  "thresholdMessage": "Water level is below the critical threshold.",
  "recommendation": "Irrigation may be needed.",
  "isRead": false,
  "source": "real",
  "createdAt": "server_timestamp"
}
```

## Example `farms` Record

```json
{
  "id": "farm_001",
  "ownerId": "firebase_user_uid",
  "farmName": "Rice Field 1",
  "deviceId": "esp32_001",
  "createdAt": "server_timestamp"
}
```

## Example `users` Record

```json
{
  "uid": "firebase_user_uid",
  "fullName": "Sample Farmer",
  "email": "farmer@example.com",
  "createdAt": "server_timestamp"
}
```

## Classification Guidance

- If all readings are within safe range, classify Field Status as `Normal`.
- If one or more readings are near unsafe range, classify Field Status as `Warning`.
- If one or more readings are severely abnormal, classify Field Status as `Critical`.
- Severity priority is `Critical > Warning > Normal`.
- Classification location is not yet decided. The architecture should choose whether classification happens on the ESP32, in Firebase/backend logic, or in the mobile app.

## Recommendation Examples

- `Irrigation may be needed.`
- `Check field water level.`
- `High temperature detected.`
- `Continue monitoring field condition.`

## Device Status Logic

Use the latest `createdAt` timestamp from `sensor_readings`.

```text
Online: latest reading is recent
Delayed: latest reading is older than expected interval
No Recent Data: no reading exists or last reading is too old
```

The freshness thresholds should remain configurable in code.

Exact freshness intervals are not yet decided.

## Coding Guidance

- Keep code simple and understandable for a student prototype.
- Prefer readable structure over over-engineered architecture.
- Use clear file names and screen names.
- Add comments only where helpful.
- Keep business logic separated from UI when practical.
- Avoid adding features outside the MVP scope.
- Make Firebase paths and thresholds easy to modify.
