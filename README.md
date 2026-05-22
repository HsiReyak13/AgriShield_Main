# AgriShield 🛡️🌾
> **Smart Agriculture IoT Monitoring & Field Protection System**

AgriShield is an advanced, enterprise-grade agricultural IoT application designed to protect crops, optimize yields, and monitor environmental variables in real-time. By bridging smart sensor hardware arrays with a robust Flutter mobile companion app and secure cloud services, AgriShield gives farmers, agronomists, and landowners immediate insight and control over their fields.

---

## 🚀 Key Features

*   **Real-Time Telemetry Dashboard:** Stream live environmental variables including soil moisture, ambient temperature, humidity, and sunlight index.
*   **Intuitive Field Mapping & Organization:** Monitor multiple zones or fields simultaneously with a custom card-based status UI.
*   **Smart Device Pairing & Onboarding:** Seamlessly register new sensor nodes (e.g., ESP32 AgriShield units) via modern in-app pairing flows.
*   **Intelligent Alerting & Thresholds:** Receive instant push notifications when crop conditions diverge from their optimal thresholds.
*   **Interactive Simulation & Demo Mode:** Built-in telemetry simulator to validate field status UI, test alert paths, and demo the app without active hardware.

---

## 🛠️ Tech Stack & Architecture

- **Mobile Client:** Flutter (SDK `^3.11.5`), Dart
- **State Management:** BLoC / Cubit (`flutter_bloc`)
- **Navigation:** GoRouter (`go_router`)
- **IoT Hardware:** ESP32 Microcontrollers, Capacitive Soil Moisture Sensors, DHT22 Temperature/Humidity Sensors, LDR Light Sensors
- **Cloud Computing Platform:** Firebase (Authentication, Cloud Firestore for real-time telemetry updates, Cloud Messaging for remote push notifications)

---

## 📂 Repository Structure

```text
AgriShield/
  ├── apps/
  │   └── mobile/        # Flutter mobile application
  └── hardware/
      └── firmware/      # ESP32 C++/Arduino firmware projects
```

---

## 📥 Installation Instructions

### Prerequisites
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (Version `3.11.5` or higher)
*   [Dart SDK](https://dart.dev/get-started)
*   [Android Studio](https://developer.android.com/studio) or [Xcode](https://developer.apple.com/xcode/) (for running simulators/emulators)

### Step-by-Step Local Setup

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/HsiReyak13/AgriShield_Main.git
    cd AgriShield_Main
    ```

2.  **Navigate to the Mobile App Directory:**
    ```bash
    cd apps/mobile
    ```

3.  **Fetch Dependencies:**
    ```bash
    flutter pub get
    ```

4.  **Launch the Mobile Application:**
    *   Ensure an emulator is active or a physical testing device is connected via USB debugging.
    *   Execute:
        ```bash
        flutter run
        ```

---

## ⚙️ Setup Guidelines

### 1. IoT Hardware & Firmware Configuration
1.  **Hardware Assembly:**
    *   Connect your capacitive soil moisture sensor, DHT22 sensor, and LDR to the ESP32 microcontroller as documented in the pinout maps inside the `hardware/firmware` directory.
2.  **Firmware Flash:**
    *   Open the firmware project in `hardware/firmware` using **VS Code with PlatformIO** or **Arduino IDE**.
    *   Create a local configuration header `config.h` specifying your local WiFi credentials and Cloud broker endpoint.
    *   Build and flash the code to your ESP32 board over a USB-C connection.

### 2. Cloud Integration Setup
*   **Firebase Project Initialization:**
    1.  Create a project in the [Firebase Console](https://console.firebase.google.com/).
    2.  Enable **Anonymous** or **Email/Password** Authentication.
    3.  Create a **Cloud Firestore** database in test mode.
    4.  Add Android and iOS apps to your Firebase project, and download the configuration files (`google-services.json` and `GoogleService-Info.plist`).
    5.  Place the config files under:
        *   Android: `apps/mobile/android/app/google-services.json`
        *   iOS: `apps/mobile/ios/Runner/GoogleService-Info.plist`

