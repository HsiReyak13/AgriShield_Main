---
title: AgriShield PH
status: draft
created: 2026-05-21
updated: 2026-05-22
source_context: C:\Users\LA\Downloads\agrishield_ph_codex_context_updated.md
---

# PRD: AgriShield PH

## 0. Document Purpose

This PRD defines the MVP requirements for AgriShield PH, a student prototype mobile application for IoT-based rice field monitoring. It is intended for the project team, UX/design work, architecture planning, implementation, and evaluation preparation. Requirements are grouped by product capability, functional requirements use stable IDs, and inferred decisions are marked with `[ASSUMPTION]` where they were not explicitly finalized in the source context.

## 1. Vision

AgriShield PH helps small rice farmers become aware of abnormal field conditions sooner by connecting low-cost field sensors to a simple mobile monitoring experience. The system reads soil moisture, water level, temperature, and humidity from an ESP32-based sensor setup, stores readings in Firebase, and presents current field status through a Flutter mobile application.

The product thesis is deliberately focused: the MVP proves an end-to-end monitoring and alert workflow, not a full smart-farming platform. Farmers should be able to open the app, understand whether the rice field is Normal, Warning, or Critical, see what reading caused concern, and review recent readings or alerts without needing technical knowledge.

AgriShield PH is monitoring-only and conceptual/prototype-oriented for MVP evaluation. It supports faster awareness and better-informed field checking, but it does not replace farmer judgment, automatically control irrigation, detect pests or disease, predict yield, or make claims beyond prototype threshold-based guidance.

## 2. Target Users

### 2.1 Primary Persona

**Small Rice Farmer** - A farmer who monitors a rice field manually and needs a simple mobile way to check basic field conditions. This user may have limited technical knowledge and needs clear language, readable values, and obvious status cues rather than complex analytics.

### 2.2 Secondary Users

**Student Researcher / Project Presenter** - A team member who needs the prototype to demonstrate a complete sensor-to-mobile workflow during testing, evaluation, or project defense.

**Agricultural Prototype Reviewer** - A teacher, evaluator, cooperative representative, local government unit, or agricultural office reviewing the feasibility of a low-cost monitoring prototype.

### 2.3 Jobs To Be Done

- View current rice field readings from a mobile phone.
- Understand whether the field condition is Normal, Warning, or Critical.
- Receive clear in-app alerts when abnormal readings are detected.
- See basic recommendations connected to the readings.
- Review previous readings and alert records.
- Demonstrate the monitoring workflow even when real sensor data is unavailable.
- Use an affordable and understandable system suitable for a small-scale farming context.

### 2.4 Key User Journeys

- **UJ-1. Small Rice Farmer checks the current field condition.**
  The Small Rice Farmer opens the mobile app, logs in if needed, lands on the Dashboard, and sees the latest soil moisture, water level, temperature, and humidity readings. The app displays the Field Status, Device Status, Last Updated timestamp, and latest recommendation. The value lands when the farmer can quickly tell whether the field appears safe or needs checking.

- **UJ-2. Small Rice Farmer responds to an abnormal reading.**
  The Small Rice Farmer opens Alerts after a Warning or Critical condition appears. The app shows the affected sensor, reading value, severity, timestamp, threshold comparison, and recommendation. The value lands when the farmer understands what changed and what basic field-checking action to consider.

- **UJ-3. Student Researcher demonstrates the system during evaluation.**
  The Student Researcher opens Demo Mode, selects or triggers simulated Normal, Warning, and Critical readings, and uses the Dashboard, Alerts, and History screens to show the complete workflow. The value lands when the project can be demonstrated even if Wi-Fi, Firebase, or hardware readings are unstable.

- **UJ-4. Small Rice Farmer reviews previous readings.**
  The Small Rice Farmer opens History, views stored sensor readings, and checks a simple trend chart. The value lands when the farmer can see whether readings have been stable, worsening, or recently abnormal.

## 3. Glossary

- **AgriShield PH** - The mobile-only IoT rice field monitoring and alert prototype described by this PRD.
- **Alert** - An in-app Warning or Critical notification generated or displayed when a Sensor Reading crosses a prototype threshold.
- **Alert History** - The stored list of previous Alerts.
- **Dashboard** - The main app screen showing Latest Readings, Field Status, Device Status, Last Updated timestamp, and latest Recommendation.
- **Demo Mode** - A clearly separated mode that uses simulated Sensor Readings for testing and project defense.
- **Device Status** - The app's freshness classification for data from the ESP32 device: Online, Delayed, or No Recent Data.
- **ESP32 Device** - The microcontroller hardware that reads connected sensors and sends Sensor Readings to Firebase through Wi-Fi.
- **Field Status** - The overall condition classification for a farm/device: Normal, Warning, or Critical.
- **Firebase** - The backend service used for authentication, data storage, and retrieval in the MVP.
- **Guide** - The app section explaining sensor meanings, threshold levels, calibration limitations, and the monitoring-only disclaimer.
- **Latest Reading** - The most recent Sensor Reading available for the current farm/device.
- **Recommendation** - A simple, non-automated guidance message tied to Sensor Readings or Field Status.
- **SEN0193** - The recommended capacitive soil moisture sensor model for the MVP.
- **Sensor Reading** - A stored record containing soil moisture, water level, temperature, humidity, Field Status, Recommendation, source, and timestamp.
- **Threshold** - A configurable prototype value used to classify Sensor Readings as Normal, Warning, or Critical.

## 4. Features

### 4.1 Authentication

**Description:** Users can register and log in with Firebase Authentication before accessing monitoring screens. Authentication should be simple and functional for MVP demonstration.

**Functional Requirements:**

#### FR-1: User Registration

Users can create an account with Firebase Authentication.

**Consequences (testable):**
- A new user can register using the required registration fields.
- A successful registration creates an authenticated app session.
- Failed registration shows a readable error message without exposing technical details.

#### FR-2: User Login

Registered users can log in with Firebase Authentication.

**Consequences (testable):**
- A registered user can log in and access the main navigation.
- Invalid credentials do not grant access and show a readable error message.
- Authentication state is respected when reopening the app. [ASSUMPTION: Session persistence will use Firebase's default mobile auth behavior unless the team chooses otherwise.]

### 4.2 Dashboard Monitoring

**Description:** The Dashboard is the farmer's primary monitoring surface. It displays Latest Reading values, Field Status, Device Status, Last Updated timestamp, and the latest Recommendation using mobile-first, readable, color-coded cards. Realizes UJ-1.

**Functional Requirements:**

#### FR-3: Latest Reading Display

The app displays the latest soil moisture, water level, temperature, and humidity values from Firebase for the current farm/device.

**Consequences (testable):**
- Each of the four sensor values appears on the Dashboard.
- Missing values are handled with an empty or unavailable state rather than incorrect defaults.
- Reading units or labels are understandable to non-technical users.

#### FR-4: Field Status Display

The app displays Field Status as Normal, Warning, or Critical based on the latest available Sensor Reading.

**Consequences (testable):**
- Normal, Warning, and Critical states are visually distinct.
- Critical has priority over Warning, and Warning has priority over Normal.
- The displayed Field Status matches the classification result for the Latest Reading.

#### FR-5: Device Status Display

The app displays Device Status as Online, Delayed, or No Recent Data using the timestamp of the Latest Reading.

**Consequences (testable):**
- Recent data displays Online.
- Older-than-expected data displays Delayed.
- Missing or too-old data displays No Recent Data.
- Device Status thresholds are configurable in code.

#### FR-6: Last Updated Timestamp

The app displays when the Latest Reading was received.

**Consequences (testable):**
- The timestamp appears on the Dashboard.
- The timestamp updates when a newer Sensor Reading is loaded.
- The app does not imply live freshness when the timestamp is old.

#### FR-7: Latest Recommendation

The app displays a simple Recommendation based on the Latest Reading or Field Status.

**Consequences (testable):**
- Normal readings can show a continue-monitoring message.
- Warning or Critical readings show a relevant field-checking recommendation.
- Recommendation text avoids claiming automatic problem resolution.

### 4.3 Status Classification and Recommendations

**Description:** The system classifies Sensor Readings into Normal, Warning, or Critical using configurable prototype Thresholds. Recommendations are simple, farmer-friendly messages tied to detected conditions. The classification location is still a technical decision and may be implemented on the ESP32 Device, in Firebase/backend logic, or inside the mobile app as long as behavior remains consistent. [NOTE FOR ARCHITECTURE: Finalize classification location before implementation stories are created.]

**Functional Requirements:**

#### FR-8: Threshold-Based Classification

The system classifies Sensor Readings using prototype Threshold values.

**Consequences (testable):**
- Readings inside the safe range classify as Normal.
- Readings near unsafe range classify as Warning.
- Severely abnormal readings classify as Critical.
- Threshold values are easy to modify for testing and calibration.

#### FR-9: Severity Priority

When multiple readings have different severities, the system uses Critical over Warning over Normal for the overall Field Status.

**Consequences (testable):**
- Any Critical sensor condition makes the Field Status Critical.
- If no sensor is Critical but at least one is Warning, the Field Status is Warning.
- Field Status is Normal only when all relevant readings are Normal.

#### FR-10: Recommendation Mapping

The system provides basic recommendations for detected conditions.

**Consequences (testable):**
- Low water level can produce a message such as "Irrigation may be needed."
- Warning water conditions can produce a message such as "Check field water level."
- High temperature can produce a message such as "High temperature detected."
- Normal conditions can produce a message such as "Continue monitoring field condition."

### 4.4 In-App Alerts

**Description:** Alerts notify users inside the mobile app when Warning or Critical conditions occur. Alerts should be useful, not noisy, and should preserve enough detail for review. Realizes UJ-2.

**Functional Requirements:**

#### FR-11: Alert Creation or Display

The system generates or displays Alerts when Sensor Readings reach Warning or Critical thresholds.

**Consequences (testable):**
- Warning readings produce Warning Alerts.
- Critical readings produce Critical Alerts.
- Normal readings do not produce abnormal-condition Alerts.

#### FR-12: Alert Details

Each Alert includes affected sensor, reading value, severity, timestamp, threshold comparison, Recommendation, read state, and source.

**Consequences (testable):**
- Opening an Alert Detail Screen shows all required Alert fields.
- Missing Alert fields are handled with readable fallback text.
- Severity is visually clear on both list and detail views.

#### FR-13: Alert History

The app stores and displays previous Warning and Critical Alerts.

**Consequences (testable):**
- Alerts are stored in Firebase.
- The Alerts Screen lists current and previous Alerts.
- Users can distinguish Alert severity and timestamp from the list.

#### FR-14: Alert Spam Prevention

The system prevents duplicate Alert spam by generating Alerts only when status changes or after a defined cooldown interval.

**Consequences (testable):**
- Repeated identical abnormal readings do not create unlimited duplicate Alerts.
- A status change can create a new Alert.
- Cooldown duration is configurable. [ASSUMPTION: The MVP may implement either status-change detection or a cooldown interval first, as long as one anti-spam rule exists.]

### 4.5 Reading History and Charts

**Description:** Users can review previous Sensor Readings and see simple trend visuals suitable for an MVP defense and basic farmer awareness. Realizes UJ-4.

**Functional Requirements:**

#### FR-15: Reading Storage

The system stores previous Sensor Readings in Firebase.

**Consequences (testable):**
- Each Sensor Reading includes farm/device identifiers, sensor values, Field Status, Recommendation, source, and timestamp.
- New readings do not overwrite all prior readings.
- Reading history can be queried by timestamp.

#### FR-16: Reading History View

The app displays previous Sensor Readings.

**Consequences (testable):**
- Users can view a chronological list or equivalent history presentation.
- Each history item includes enough information to identify sensor values and status.
- Empty history shows a readable empty state.

#### FR-17: Simple Chart View

The app displays basic trends from stored Sensor Readings.

**Consequences (testable):**
- At least one chart or trend view is available from History or a Chart Screen.
- The chart uses stored Firebase readings.
- The chart remains basic and readable rather than advanced analytics.

### 4.6 Guide and Threshold Information

**Description:** The Guide explains what the sensors mean, how status levels work, what prototype Thresholds are, and why calibration matters. It also makes the monitoring-only limitation explicit.

**Functional Requirements:**

#### FR-18: Sensor Explanation

The Guide explains soil moisture, water level, temperature, and humidity in farmer-friendly language.

**Consequences (testable):**
- Each sensor has a short explanation.
- Explanations avoid unnecessary technical jargon.

#### FR-19: Threshold and Status Explanation

The Guide explains Normal, Warning, and Critical status levels and prototype Threshold limitations.

**Consequences (testable):**
- Users can understand the meaning of each Field Status.
- Prototype Threshold values or descriptions are visible.
- Calibration limitations are stated plainly.

#### FR-20: Monitoring-Only Disclaimer

The Guide states that AgriShield PH supports awareness and field checking but does not automatically solve irrigation, pest, disease, fertilizer, or yield problems.

**Consequences (testable):**
- The disclaimer is visible in the Guide.
- Recommendation text remains consistent with the disclaimer.

### 4.7 Demo Mode

**Description:** Demo Mode provides simulated Normal, Warning, and Critical readings for testing and project defense backup. Demo data must be clearly separated from real sensor data. Realizes UJ-3.

**Functional Requirements:**

#### FR-21: Simulated Reading Scenarios

Demo Mode includes simulated Normal, Warning, and Critical Sensor Readings.

**Consequences (testable):**
- Users can demonstrate all three Field Status states without hardware.
- Simulated readings include all four sensor values.
- Simulated readings drive the same visible Dashboard/Alert behavior expected in the demo flow.

#### FR-22: Demo Data Separation

The app clearly separates Demo Mode data from real Sensor Readings.

**Consequences (testable):**
- Demo readings are labeled or stored with `source: "demo"`.
- Real readings are labeled or stored with `source: "real"`.
- Users are not led to believe Demo Mode readings came from the ESP32 Device.

### 4.8 About Project

**Description:** The About Project screen explains the project's purpose, technologies, scope, limitations, and student prototype context.

**Functional Requirements:**

#### FR-23: Project Explanation

The app includes an About Project screen.

**Consequences (testable):**
- The screen names the project purpose.
- The screen lists the major technologies: Flutter, Firebase, ESP32, and connected sensors.
- The screen states the MVP scope and major limitations.

### 4.9 Navigation and Screen Structure

**Description:** The mobile app uses a simple navigation model that keeps the core farmer workflow easy to reach.

**Functional Requirements:**

#### FR-24: Required Screen Set

The app includes Splash, Login, Register, Dashboard, Alerts, Alert Detail, History, Chart, Guide / Threshold Info, Demo Mode, and About Project screens.

**Consequences (testable):**
- Each required screen is reachable through the app flow.
- Screens match the mobile-first prototype scope.
- Screen labels are readable and farmer-friendly.

#### FR-25: Bottom Navigation

The app uses bottom tabs for Dashboard, Alerts, History, and More. [ASSUMPTION: The bottom navigation structure from the source context is the intended MVP navigation.]

**Consequences (testable):**
- Dashboard, Alerts, History, and More are accessible from the main authenticated area.
- More provides access to Guide, Demo Mode, About Project, and logout.
- Navigation remains usable on mobile screen sizes.

## 5. Information Architecture and UI Direction

The app is mobile-only and should follow the supplied mockups as the source of truth for layout, navigation, spacing, labels, card structure, and overall visual style. If implementation time is limited, all screens from the Lovable and shared ChatGPT mockups remain mandatory; scope should be reduced through interaction depth or backend completeness only when necessary, not by dropping mockup-covered screens. The design should remain clean, readable, accessible, and farmer-friendly.

Required design characteristics:

- Mobile-first screens.
- Rounded cards, clear icons, readable labels, and dashboard-style summaries.
- Clear status colors for Normal, Warning, and Critical.
- Color-coded reading cards for quick scanning.
- Minimal technical jargon.
- No out-of-scope features added for decorative or speculative reasons.

Design references:

- Primary mockup reference: Lovable preview URL from the source context.
- Shared design reference: ChatGPT shared design/mockup conversation from the source context. [ASSUMPTION: The team will use this only when accessible in the project environment.]

## 6. Data Requirements

### 6.1 Required Collections

The MVP uses Firebase collections for:

- `users`
- `farms`
- `sensor_readings`
- `alerts`

### 6.2 Sensor Reading Record

Each `sensor_readings` record should support:

- `id`
- `farmId`
- `deviceId`
- `soilMoisture`
- `waterLevel`
- `temperature`
- `humidity`
- `fieldStatus`
- `recommendation`
- `source`
- `createdAt`

### 6.3 Alert Record

Each `alerts` record should support:

- `id`
- `farmId`
- `deviceId`
- `sensor`
- `severity`
- `readingValue`
- `thresholdMessage`
- `recommendation`
- `isRead`
- `source`
- `createdAt`

### 6.4 Farm Record

Each `farms` record should support:

- `id`
- `ownerId`
- `farmName`
- `deviceId`
- `createdAt`

### 6.5 User Record

Each `users` record should support:

- `uid`
- `fullName`
- `email`
- `createdAt`

## 7. Cross-Cutting Non-Functional Requirements

### 7.1 Usability

- The current Field Status must be understandable without technical knowledge.
- Alerts and Recommendations must use clear, direct language.
- Users should be able to navigate Dashboard, Alerts, History, and More with minimal guidance.

### 7.2 Reliability and Offline/Delayed Data Handling

- The app must distinguish fresh data from delayed or missing data.
- The app must avoid silently treating stale data as current.
- Demo Mode must be available as a presentation backup when hardware, Wi-Fi, or Firebase are unavailable.

### 7.3 Safety and Claims

- The app must not claim to automatically control irrigation or solve farming problems.
- Recommendations must be framed as basic field-checking guidance.
- Threshold and calibration limitations must be visible to users.

### 7.4 Security and Privacy

- Authentication must protect access to monitoring screens.
- Firebase data should be scoped so users access only the MVP demonstration user's data and the single conceptual farm/device data. [NOTE FOR ARCHITECTURE: Firebase security rules are not yet defined and must be specified before implementation or defense data entry.]

### 7.5 Maintainability

- Thresholds and device freshness intervals must be easy to modify.
- Business logic should be separated from UI when practical.
- Code should remain simple and understandable for a student prototype.

## 8. Hardware and Environment Constraints

- The ESP32 Device requires Wi-Fi connectivity to send readings to Firebase.
- The recommended soil moisture sensor is SEN0193.
- The temperature and humidity sensor is DHT22.
- Low-cost sensors may be less durable or accurate in wet field environments.
- Prototype Threshold values require testing and calibration before any real deployment use.
- The MVP supports one conceptual farm and one prototype device only. It is not expected to be tested in an actual farm during MVP evaluation.
- Users are expected to have access to an Android smartphone capable of running the Flutter mobile app. [ASSUMPTION: Android is the primary demonstration target because the source context describes a mobile app but not a final platform store target.]

## 9. MVP Scope

### 9.1 In Scope

- Firebase setup for authentication and MVP data storage.
- SEN0193 soil moisture sensor and DHT22 temperature/humidity sensor as the named hardware baseline.
- User registration and login.
- Dashboard with Latest Readings, Field Status, Device Status, Last Updated timestamp, and latest Recommendation.
- Threshold-based status classification.
- In-app Warning and Critical Alerts.
- Alert Detail and Alert History.
- Sensor Reading History.
- Simple Chart View.
- Guide / Threshold Info.
- Demo Mode with clearly separated simulated readings.
- About Project screen.
- UI polish based on supplied mockups.

### 9.2 Out of Scope for MVP

- SMS alerts.
- Web application or web dashboard.
- Automatic irrigation control.
- Pest detection.
- Disease detection.
- Fertilizer guidance.
- Yield prediction.
- AI-based recommendations.
- Multi-farm management.
- Real farm deployment or field validation.
- Advanced analytics.
- Exportable reports.
- Commercial deployment readiness.

## 10. Success Metrics

### 10.1 Functional Success Metrics

- **SM-1:** ESP32 can send Sensor Readings to Firebase through Wi-Fi. Validates FR-15 and the end-to-end system flow.
- **SM-2:** The mobile app displays soil moisture, water level, temperature, and humidity from Firebase. Validates FR-3.
- **SM-3:** The system correctly classifies Field Status as Normal, Warning, or Critical based on prototype Thresholds. Validates FR-4, FR-8, and FR-9.
- **SM-4:** Warning and Critical Alerts appear in the app and are saved in Alert History. Validates FR-11, FR-12, and FR-13.
- **SM-5:** Previous Sensor Readings are saved and viewable in the app. Validates FR-15 and FR-16.
- **SM-6:** Recommendations appear based on detected conditions. Validates FR-7 and FR-10.
- **SM-7:** Demo Mode can simulate Normal, Warning, and Critical readings. Validates FR-21 and FR-22.
- **SM-8:** Users can register, log in, and access monitoring screens. Validates FR-1 and FR-2.

### 10.2 Usability Success Metrics

- **SM-9:** Users can identify the current Field Status without needing technical knowledge. Validates FR-4, FR-18, and FR-19.
- **SM-10:** Users can navigate Dashboard, Alerts, History, and More with minimal guidance. Validates FR-24 and FR-25.
- **SM-11:** Users interpret Recommendations as field-checking guidance, not automatic farming decisions. Validates FR-20.

### 10.3 Counter-Metrics

- **SM-C1:** Do not optimize for number of Alerts generated; excessive Alerts can reduce trust and usefulness. Counterbalances SM-4 and validates FR-14.
- **SM-C2:** Do not optimize for adding more screens or features beyond MVP scope; scope creep risks weakening the end-to-end sensor-to-mobile workflow. Counterbalances the full feature set.
- **SM-C3:** Do not optimize for confident recommendation language; the prototype should remain honest about calibration and monitoring-only limits. Counterbalances SM-6.

## 11. Risks and Mitigations

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Hardware or sensor failure | The app may display incorrect Field Status or inaccurate Alerts. | Test each sensor separately, validate readings, and consider simple averaging where practical. |
| Wi-Fi or Firebase connection failure | The app may not receive updated readings. | Show Last Updated timestamp, Device Status, and provide Demo Mode. |
| Alert duplication | Alert History may become crowded and confusing. | Generate Alerts only on status change or after a configurable cooldown interval. |
| Scope creep | The project may become too large to finish. | Keep MVP limited to monitoring, Firebase, mobile viewing, in-app Alerts, Recommendations, and History. |
| Prototype Threshold limitations | Field Status may not match all real field conditions, especially because the MVP is conceptual and not expected to be tested in an actual farm. | Include threshold information and calibration disclaimer. |
| Timeline risk | The UI may look complete while the sensor-to-mobile workflow is incomplete. | Build the core flow before secondary polish. |

## 12. Recommended Development Sequence

1. Finalize hardware components.
2. Test each sensor separately.
3. Create Firebase structure.
4. Connect ESP32 to Firebase.
5. Build the Flutter Dashboard first.
6. Implement status classification.
7. Implement in-app Alerts.
8. Add Alert History and Reading History.
9. Add simple charts.
10. Add Guide / Threshold Info.
11. Add Demo Mode.
12. Polish UI based on mockups.
13. Conduct functional, Firebase, alert, history, recommendation, and usability tests.

## 13. Open Questions

1. How often will the ESP32 send readings to Firebase?
2. Will alert classification happen on the ESP32 Device, in Firebase functions/backend logic, or inside the mobile app?
3. Will duplicate Alerts be prevented by status-change detection, cooldown interval, or both?
4. What exact Threshold values will be used during testing?
5. What freshness interval defines Online, Delayed, and No Recent Data?
6. What Firebase security rules are required for the demonstration and evaluation environment?

## 14. Assumptions Index

- FR-2 - Session persistence will use Firebase's default mobile auth behavior unless the team chooses otherwise.
- FR-14 - The MVP may implement either status-change detection or a cooldown interval first, as long as one anti-spam rule exists.
- FR-25 - The bottom navigation structure from the source context is the intended MVP navigation.
- Section 5 - The shared ChatGPT design reference will be used only when accessible in the project environment.
- Section 8 - Android is the primary demonstration target because the source context describes a mobile app but not a final platform store target.

## 15. Resolved Decisions

- Soil moisture sensor model: SEN0193.
- Temperature and humidity sensor: DHT22.
- MVP farm/device scope: one conceptual farm and one prototype device only.
- Farm testing expectation: MVP is conceptual and not expected to be tested in an actual farm.
- Mockup priority: all Lovable and shared ChatGPT mockup-covered screens are mandatory if implementation time is limited.
