---
stepsCompleted: [1, 2, 3, 4, 5]
lastStep: 5
inputDocuments:
  - C:\Users\LA\Documents\AppDev\AgriShield\_bmad-output\planning-artifacts\prds\prd-AgriShield-2026-05-21\prd.md
  - C:\Users\LA\Documents\AppDev\AgriShield\_bmad-output\planning-artifacts\ux-design-specification.md
workflowType: 'architecture'
project_name: 'AgriShield'
user_name: 'LA'
date: '2026-05-22'
status: 'in-progress'
---

# Architecture Decision Document

_This document builds collaboratively through step-by-step discovery. Sections are appended as we work through each architectural decision together._

## Project Context Analysis

### Requirements Overview

**Functional Requirements:**
AgriShield PH has 25 functional requirements across authentication, dashboard monitoring, threshold-based classification, recommendations, in-app alerts, alert history, reading history, charts, guide content, demo mode, about/project explanation, and mobile navigation.

Architecturally, the system must support an end-to-end monitoring loop:

- A prototype ESP32 device collects soil moisture, water level, temperature, and humidity readings.
- Readings are stored with farm/device identifiers, source, status, recommendation, and timestamp.
- The app displays the latest reading, field status, device freshness, recommendation, and history.
- Warning and Critical conditions create or display alerts with enough detail for user review.
- Demo Mode can simulate Normal, Warning, and Critical scenarios without confusing simulated data with real sensor data.

The PRD intentionally keeps the MVP focused on monitoring and awareness. It excludes automatic irrigation, AI recommendations, pest/disease detection, yield prediction, multi-farm management, SMS alerts, reports, and commercial deployment readiness.

**Non-Functional Requirements:**
The major NFR drivers are:

- Usability: farmers must understand status and recommendations without technical knowledge.
- Reliability: stale, delayed, missing, or unavailable readings must never appear current.
- Safety: recommendations must remain field-check guidance, not diagnosis or automated farming decisions.
- Security and privacy: authenticated users should access only the intended MVP demonstration data.
- Maintainability: thresholds, freshness intervals, and business rules must be easy to modify.
- Accessibility: the UX targets WCAG 2.1 AA, large tap targets, color-plus-label status communication, readable charts, and mobile outdoor readability.
- Demo resilience: Demo Mode must support project defense when hardware, Wi-Fi, or Firebase are unstable.

**Scale & Complexity:**

- Primary domain: mobile IoT monitoring and alerting
- Complexity level: medium
- Estimated architectural components: authentication, sensor ingestion, data storage, status classification, recommendation mapping, alert handling, dashboard state resolution, history/charting, demo data, guide/about content, and security rules

### Technical Constraints & Dependencies

Known constraints and dependencies:

- Intended product stack from the PRD is Flutter, Firebase, ESP32, and connected sensors.
- Current local workspace is a Laravel 12 application, which should be reconciled before implementation planning.
- Firebase is required for authentication and MVP data storage.
- Required Firebase collections are `users`, `farms`, `sensor_readings`, and `alerts`.
- Hardware baseline includes ESP32, SEN0193 soil moisture sensor, DHT22 temperature/humidity sensor, and Wi-Fi connectivity.
- MVP scope is one conceptual farm and one prototype device.
- Android is the assumed primary mobile demonstration target.
- Classification location is unresolved and must be finalized before implementation.
- Firebase security rules are not yet defined and must be specified before realistic testing or defense data entry.
- Exact thresholds, reading interval, freshness interval, and alert cooldown/status-change policy remain open architecture inputs.

### Cross-Cutting Concerns Identified

- Global trust state resolution for No Data, Offline, Stale, Critical, Warning, Healthy, Demo, Loading, and Error states.
- Freshness and device status logic using timestamps and configurable intervals.
- Threshold-based classification with severity priority: Critical over Warning over Normal.
- Alert deduplication through status-change detection, cooldown interval, or both.
- Demo/live data separation using explicit source labels and persistent Demo Mode indicators.
- Farmer-readable recommendation and alert language that avoids unsupported claims.
- Consistent status presentation using label, icon, color, explanation, and screen-reader support.
- Authenticated data access and Firebase rule design.
- History and chart fallback behavior for sparse, stale, offline, or demo data.
- Maintainable separation between UI, status logic, thresholds, recommendations, and data access.

## Starter Template Evaluation

### Primary Technology Domain

Mobile app based on the PRD and UX specification.

The intended product architecture is a Flutter Android-first mobile app connected to Firebase and an ESP32 sensor device. The current repository is a Laravel 12 application, so implementation planning must explicitly decide whether to create a new Flutter app workspace for the product or reinterpret the product as a Laravel-based web prototype.

### Starter Options Considered

**Option 1: Flutter Official Starter**

Use Flutter's official project generator:

```bash
flutter create agrishield_ph
```

This creates a standard Flutter application with the official project structure, Android support, Dart analysis, test support, and normal Flutter tooling.

Best fit when the team wants the simplest, most familiar Flutter foundation with minimal generated architecture.

**Option 2: Very Good CLI Flutter Starter**

Use Very Good CLI:

```bash
dart pub global activate very_good_cli
very_good create flutter_app agrishield_mobile --desc "AgriShield PH rice field monitoring app" --org "ph.agrishield"
```

This creates a more opinionated Flutter foundation with feature-oriented structure, Bloc/Cubit state management, testing conventions, localization, flavors, logging, linting, and GitHub Actions.

Best fit when the team wants AI agents to follow stricter structure and testing conventions across dashboard, alerts, history, guide, demo mode, and Firebase integration.

**Option 3: Continue in Existing Laravel Workspace**

Keep the current Laravel 12 + Livewire/Volt workspace and build AgriShield as a web application instead of the documented Flutter mobile app.

This fits the current codebase, but conflicts with the PRD's mobile-only Flutter/Firebase direction and would require updating the PRD/UX assumptions.

### Selected Starter: Very Good CLI Flutter Starter

**Rationale for Selection:**

Very Good CLI is the strongest match for the documented product because AgriShield has many repeated stateful screens, strict trust-state behavior, alert/history flows, demo/live separation, and accessibility requirements. Its feature-oriented structure and testing conventions give AI agents clearer implementation boundaries than a bare Flutter starter.

The Laravel workspace should remain useful for documentation, planning, or a separate web prototype, but it should not be treated as the primary implementation base unless the product direction changes.

The selection is conditional: Very Good CLI is adopted as a disciplined foundation, not as permission to expand MVP scope. The first implementation milestone must prove the sensor-to-mobile vertical slice before app polish or broad feature work.

**Initialization Command:**

```bash
dart pub global activate very_good_cli
very_good create flutter_app agrishield_mobile --desc "AgriShield PH rice field monitoring app" --org "ph.agrishield"
cd agrishield_mobile
flutter pub get
dart pub global activate flutterfire_cli
flutterfire configure
```

**Architectural Decisions Provided by Starter:**

**Language & Runtime:**
Dart and Flutter, aligned with the PRD's mobile-first app direction.

**Styling Solution:**
Flutter Material components customized into the AgriShield Field Material design layer from the UX specification.

**Build Tooling:**
Flutter CLI build and run tooling, with generated Android/iOS/Web/Windows flavor support from the Very Good starter where applicable.

**Testing Framework:**
Flutter unit and widget tests, with coverage-oriented defaults from the Very Good starter. Additional required tests should cover trust-state resolution, Firebase stream behavior, stale/offline transitions, demo mode separation, alert deduplication, and chart empty states.

**Code Organization:**
Feature-oriented Flutter structure using views plus Bloc/Cubit-style state management. Recommended feature boundaries include authentication, dashboard, alerts, history, guide, demo mode, settings/device recovery, and shared trust/status logic.

**Development Experience:**
Hot reload, Flutter analyzer, linting, test tooling, localization scaffolding, environment flavors, and Firebase setup through FlutterFire CLI.

### Conditional Adoption Constraints

- MVP stays Android-first.
- Laravel remains docs/planning only unless an explicit backend API requirement is added.
- Firebase setup happens immediately after app creation, not after UI polish.
- First deliverable is a vertical slice: ESP32 or mock reading, Firebase or repository data source, Android Dashboard, and one threshold alert condition.
- Mock/demo data path is implemented before live ESP32 wiring to protect evaluation reliability.
- Starter features unused by the MVP demonstration are ignored.
- Architecture remains thin: avoid premature domain layers for every screen and avoid backend abstraction without a concrete runtime need.
- If the starter's generated complexity blocks the sensor-to-mobile vertical slice, fall back to the official Flutter starter.

### Initial Test Targets

- `sensor_reading_model_test.dart`
- `trust_state_resolver_test.dart`
- `sensor_repository_mock_test.dart`
- Dashboard trust indicator widget test

**Note:** Project initialization using this command should be the first implementation story.

## Core Architectural Decisions

### Decision Priority Analysis

**Critical Decisions (Block Implementation):**

- Primary runtime is a Flutter Android-first mobile app.
- Existing Laravel workspace remains planning/docs/static artifacts only for MVP.
- Firebase Realtime Database is the MVP backend runtime.
- ESP32 writes telemetry directly to Firebase RTDB.
- Flutter reads RTDB through repository interfaces.
- No Firebase Auth for the conceptual MVP.
- Device-code pairing replaces login/registration.
- Device code is a prototype pairing token, not authentication, ownership, revocation, or a production security model.
- Demo Mode is separate from live device data.
- Use `flutter_bloc` with mostly Cubits for state management.
- Use `go_router` for navigation.
- Use explicit `DataSource`, `TrustState`, and `FieldStatus` domain models.
- Use one Firebase RTDB demo project and one Android APK deployment target.

**Important Decisions (Shape Architecture):**

- App reads/writes no personal farmer account data.
- RTDB paths and payload shapes must be documented before app/firmware implementation.
- UI never imports Firebase directly.
- Cubits and views do not parse RTDB payloads.
- Repository/data-source layer owns Firebase details.
- Flutter app logic owns MVP field-status classification, using configurable prototype thresholds from RTDB/device config when available.
- Trust state is product architecture, not just UI decoration.
- Demo Mode uses distinct data providers but the same UI contracts.
- RTDB rules must be committed, reviewed, and evidenced before defense.
- A demo runbook is required before evaluation.

**Deferred Decisions (Post-MVP):**

- Firebase Authentication and user accounts.
- Per-user ownership, revocation, audit trails, and production access control.
- Multi-farm and multi-user permissions.
- Cloud Functions or backend validation.
- Firestore bridge or migration.
- Laravel/API backend.
- Laravel queue/scheduler bridge.
- Push/SMS notifications.
- Production CI/CD.
- Automated firmware delivery/update pipeline.
- Store release signing and app store deployment.
- Production monitoring/observability.
- Advanced analytics and reporting.
- Commercial deployment hardening.

### Data Architecture

Use Firebase Realtime Database as the MVP data store.

RTDB is selected over Firestore because ESP32 integration and realtime telemetry reliability matter more than richer querying for this conceptual prototype.

Primary paths:

```text
/devices/{deviceCode}/latest
/devices/{deviceCode}/readings/{readingId}
/devices/{deviceCode}/config
```

ESP32 owns telemetry writes to both `/devices/{deviceCode}/latest` and `/devices/{deviceCode}/readings/{readingId}`. Flutter must not write telemetry history.

Each reading should include:

```json
{
  "deviceCode": "AGRI01",
  "temperature": 31.4,
  "humidity": 78.2,
  "soilMoisture": 542,
  "waterLevel": 18.6,
  "createdAt": 1716361200000,
  "source": "live",
  "firmwareVersion": "0.1.0"
}
```

Dashboard listens to `/latest`. History queries `/readings` under the paired device path ordered by timestamp. Demo data is local/offline or otherwise separate from live RTDB paths.

Required data-architecture artifacts:

```text
docs/architecture/firebase-rtdb-schema.md
docs/architecture/firebase-rtdb-rules.md
apps/flutter_app/test/fixtures/rtdb/latest_ok.json
apps/flutter_app/test/fixtures/rtdb/latest_stale.json
apps/flutter_app/test/fixtures/rtdb/latest_malformed.json
```

### Authentication & Security

Do not require user registration or login for the conceptual MVP.

The first-run flow is:

```text
Splash -> Connect Device -> Dashboard
```

A user enters a device code to pair the app with a conceptual IoT device/farm. Returning users go directly to Dashboard if a saved connection exists.

Use a `DeviceConnectionRepository` to:

- resolve the device code,
- save the connected device locally,
- clear/change device connection,
- distinguish paired live data from Demo Mode.

Preferred pairing lookup model:

```text
deviceCodes/{codeHash} -> farmId, deviceId, active
```

The device code is prototype-grade pairing, not production authentication. It is not identity, ownership, revocation, or a multi-tenant security model. The demo project should store no personal farmer data. If the demo Firebase project is compromised, all prototype readings should be treated as compromised; this is acceptable only because the project is disposable and non-sensitive.

UI copy should say `Connect Device`, `Device code`, and `Live Device Connected`; it should not say `Login` or imply secure user authentication.

Security rules and the demo runbook must include evidence that rules were reviewed before defense, such as an exported rules file or screenshot of deployed RTDB rules.

### API & Communication Patterns

Use Firebase-native communication. No REST API, GraphQL API, Laravel runtime, Cloud Functions, or custom backend is included in the MVP.

MVP communication flow:

```text
ESP32 -> Firebase RTDB -> Flutter repositories -> UI
```

ESP32 writes sensor readings at a configurable interval. Flutter subscribes through repository streams.

Repository contract:

- Dashboard uses realtime listener on latest reading.
- History uses timestamp-limited RTDB queries.
- Demo Mode uses separate fixtures/data source.
- UI never imports Firebase directly.
- Repository methods return typed app states rather than raw Firebase errors.
- Repositories tolerate malformed payloads, missing values, impossible ranges, clock drift, duplicate readings, and out-of-order writes.

Core communication acceptance criteria:

- ESP32 can write readings at a configured interval.
- Flutter dashboard updates within a few seconds.
- Wi-Fi drop/reconnect is handled without re-pairing.
- History can load recent readings without unbounded scans.
- Demo Mode remains available if hardware or Wi-Fi fails.

### Frontend Architecture

Use `flutter_bloc` with mostly Cubits.

Use full Bloc only if a feature has genuinely complex event sequencing. Constructor injection is enough for MVP unless complexity forces a stronger dependency pattern.

Use `go_router` with a small route map:

```text
/pair
/field
/field/:id
/demo
/settings
```

Suggested structure:

```text
lib/
  app/
    app.dart
    router.dart
    theme/
  core/
    firebase/
    models/
      data_source.dart
      trust_state.dart
      field_status.dart
    widgets/
      trust_badge.dart
      field_status_card.dart
  features/
    pairing/
      data/
      cubit/
      view/
    dashboard/
      data/
      cubit/
      view/
    demo_mode/
      data/
      cubit/
      view/
```

Core models:

- `DataSource`: `live`, `demo`, `unknown`
- `TrustState`: `noData`, `offline`, `stale`, `critical`, `warning`, `healthy`, `demo`, `loading`, `error`
- `FieldStatus`: `normal`, `warning`, `critical`

Trust priority:

```text
No Data > Offline > Stale > Critical > Warning > Healthy
```

Shared trust widgets should be built early:

- `TrustBadge`
- `LastUpdatedText`
- `SourceIndicator`
- `FieldStatusPanel`

Guardrails:

- No Firebase imports in UI.
- No Firebase imports in Cubits.
- Views do not parse RTDB payloads.
- Demo Mode cannot mutate paired-device state.
- Every sensor value carries trust/source metadata.
- Demo Mode uses repository-level source switching, not scattered UI conditionals.

### Infrastructure & Deployment

Use one Firebase RTDB demo project and one Android APK deployment target.

No Laravel runtime, Cloud Functions, custom backend, Firestore bridge, production CI/CD, or scaling work is included in MVP.

The Laravel workspace may contain documentation, planning artifacts, and static exported artifacts only. It must not provide telemetry API endpoints, runtime database dependencies, or queue/scheduler bridges for the MVP.

Minimum build path:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

Required config files:

```text
android/app/google-services.json
lib/firebase_options.dart
firebase.json
database.rules.json
pubspec.yaml
```

Do not commit Firebase Admin service account keys.

ESP32 firmware is deployed manually from Arduino IDE or PlatformIO. Firmware folder should include:

```text
firmware/agri_sensor/README.md
firmware/agri_sensor/config.example.h
```

Real `config.h` must be ignored.

RTDB rules must be written and reviewed before defense. The rules should constrain expected demo device paths, validate reading shape where practical, and avoid storing sensitive data.

A demo runbook is required:

```text
docs/runbooks/demo.md
```

The runbook must include:

- Firebase project name
- RTDB path contract
- device code
- firmware version
- APK version
- Wi-Fi setup
- fallback steps
- manual Firebase data injection steps
- Demo Mode fallback
- evidence of deployed RTDB rules review

Fallback tiers:

1. Real ESP32 + RTDB + release APK.
2. Manual Firebase data injection + release APK.
3. Offline Demo Mode with realistic scenarios.
4. Screenshots/video only if every live path fails.

### MVP Proof Points

The MVP architecture must prove:

- A live ESP32 reading appears in the app.
- A stale/offline state appears when telemetry stops or Firebase is unavailable.
- A threshold breach creates Warning/Critical field status.
- Demo Mode works without hardware.
- Device pairing can be reset/repeated during presentation.
- The user can understand field status without reading raw sensor noise.

### Quality Gates

Before implementation is considered ready for defense:

- RTDB schema contract is documented.
- RTDB rules checklist is completed.
- Repository tests map RTDB payloads to `FieldStatus`.
- Repository tests map malformed, missing, stale, impossible-range, duplicate, and out-of-order data to `TrustState`.
- Cubit tests cover paired, unpaired, stale, demo, malformed, and offline states.
- Cubit tests prove no Firebase SDK dependency in Cubits.
- Demo Mode tests prove no RTDB calls and no live-state mutation.
- Routing tests verify demo and live flows are separate.
- End-to-end live demo script proves ESP32 write -> RTDB latest update -> Flutter trusted live state.
- Failure demo script proves RTDB unavailable or device silent -> graceful degraded state.

### Decision Impact Analysis

**Implementation Sequence:**

1. Initialize Flutter app with Very Good CLI.
2. Configure Firebase RTDB through FlutterFire.
3. Define RTDB schema contract and security rules.
4. Create device pairing flow.
5. Build RTDB reading repository.
6. Build dashboard vertical slice with trust states.
7. Add Demo Mode data source.
8. Add history and alert/recommendation behavior.
9. Add firmware documentation and ESP32 write path.
10. Build release APK and run defense rehearsal.

**Cross-Component Dependencies:**

- RTDB schema must be agreed before ESP32 firmware and Flutter repository implementation.
- ESP32 owns telemetry writes to both latest and historical reading paths.
- Device-code pairing controls app routing and live RTDB path selection.
- Flutter app classification logic owns MVP Field Status, using configurable thresholds when available.
- Trust-state resolver affects Dashboard, Alerts, History, Demo Mode, and recovery states.
- Demo Mode must share UI contracts with live data while staying technically separate.
- RTDB rules and schema shape must match repository queries.
- Release APK, firmware version, Firebase project, and demo runbook must stay aligned for defense.

## Implementation Patterns & Consistency Rules

### Pattern Categories Defined

**Critical Conflict Points Identified:**

The architecture has 10 high-risk consistency points where AI agents could make incompatible choices:

- RTDB path naming and ownership
- RTDB JSON field naming and payload shape
- telemetry history writer ownership
- Firebase import boundaries
- Cubit state naming and transitions
- Demo Mode data-source separation
- threshold and trust-state classification ownership
- route naming and redirect behavior
- test and fixture placement
- runbook, firmware, and configuration file placement

### Naming Patterns

**RTDB Naming Conventions:**

- Use lowercase plural path segments.
- Use camelCase JSON field names.
- Use `deviceCode` as the MVP device path key.
- Use epoch milliseconds in `createdAt`.
- Use `readingId` for historical reading children.
- Use `source` values of `live` or `demo`.

Canonical RTDB paths:

```text
/devices/{deviceCode}/latest
/devices/{deviceCode}/readings/{readingId}
/devices/{deviceCode}/config
```

Do not introduce alternate paths such as `/sensorReadings`, `/Sensors`, `/history`, `/device/{id}`, or global `/readings/{readingId}` without updating the schema contract first.

**Payload Field Conventions:**

Use these field names consistently:

```json
{
  "deviceCode": "AGRI01",
  "temperature": 31.4,
  "humidity": 78.2,
  "soilMoisture": 542,
  "waterLevel": 18.6,
  "createdAt": 1716361200000,
  "source": "live",
  "firmwareVersion": "0.1.0"
}
```

Avoid snake_case (`soil_moisture`), PascalCase (`SoilMoisture`), mixed timestamp names (`timestamp`, `dateCreated`, `created_at`), or unit-specific field names unless the schema contract is updated.

**Code Naming Conventions:**

- Dart files use `snake_case.dart`.
- Dart classes, widgets, Cubits, and states use `PascalCase`.
- Dart variables, methods, and fields use `camelCase`.
- Feature folders use lowercase snake_case only when the name has multiple words.
- Prefer feature names that match product jobs: `pairing`, `dashboard`, `history`, `demo_mode`, `settings`.

Examples:

```text
device_connection_repository.dart
reading_repository.dart
trust_state_resolver.dart
dashboard_cubit.dart
field_status_panel.dart
```

### Structure Patterns

**Project Organization:**

Use feature-first Flutter organization with a small shared core.

```text
lib/
  app/
    app.dart
    router.dart
    theme/
  core/
    firebase/
    models/
    repositories/
    widgets/
  features/
    pairing/
      data/
      cubit/
      view/
    dashboard/
      data/
      cubit/
      view/
    demo_mode/
      data/
      cubit/
      view/
    history/
      data/
      cubit/
      view/
    settings/
      view/
```

Add a `domain/` folder inside a feature only when that feature has logic shared by multiple screens or tests. Do not add use-case/interactor layers by default.

**Firebase Boundary:**

Firebase SDK imports are allowed only in repository/data-source implementation files under `data/` or `core/firebase/`.

Forbidden:

- importing `firebase_database` in widgets,
- importing `firebase_database` in Cubits,
- parsing RTDB snapshots inside views,
- building RTDB paths inside UI files.

**Telemetry Ownership:**

ESP32 owns telemetry writes to both:

```text
/devices/{deviceCode}/latest
/devices/{deviceCode}/readings/{readingId}
```

Flutter must not write live telemetry history. Flutter may write local app preferences only, such as saved `deviceCode`, selected demo scenario, or UI state.

**Documentation and Fixture Placement:**

Architecture and deployment support files use these paths:

```text
docs/architecture/firebase-rtdb-schema.md
docs/architecture/firebase-rtdb-rules.md
docs/runbooks/demo.md
apps/flutter_app/test/fixtures/rtdb/latest_ok.json
apps/flutter_app/test/fixtures/rtdb/latest_stale.json
apps/flutter_app/test/fixtures/rtdb/latest_malformed.json
firmware/agri_sensor/README.md
firmware/agri_sensor/config.example.h
```

Real firmware secrets and local Wi-Fi credentials must stay out of version control.

### Format Patterns

**Data Exchange Formats:**

- JSON fields use camelCase.
- Sensor numeric values use numbers, not strings.
- `createdAt` uses epoch milliseconds.
- Missing optional values map to explicit `TrustState` outcomes; they must not silently default to healthy.
- Invalid or impossible values are treated as untrusted/malformed input.

**Status Values:**

Use these canonical enum-style values in app code:

```text
DataSource: live, demo, unknown
TrustState: noData, offline, stale, critical, warning, healthy, demo, loading, error
FieldStatus: normal, warning, critical
```

UI labels may be friendlier (`Stable`, `Needs attention`, `Critical`), but internal values must stay consistent.

**Threshold Configuration Format:**

Thresholds belong in `/devices/{deviceCode}/config` when available. Flutter owns MVP classification, using config thresholds when valid and falling back to documented prototype defaults when config is missing.

Threshold config must not be edited from the mobile app in MVP unless a later architecture decision explicitly allows it.

### Communication Patterns

**Repository Contracts:**

Repositories return typed app/domain models, not raw Firebase snapshots.

Expected repository responsibilities:

- build RTDB paths,
- parse snapshot payloads,
- validate field presence and types,
- detect malformed data,
- map readings to trust/source metadata,
- expose streams or futures to Cubits,
- keep demo and live data sources separate.

**State Management Patterns:**

Use Cubits for MVP flows. Cubit states should be immutable and screen-ready.

Canonical state fields:

```text
status/loading marker
dataSource
trustState
fieldStatus
lastUpdated
reading
message
```

Do not expose raw exceptions or Firebase snapshots to views. Do not let views infer stale/offline/demo state from low-level data.

**Routing Patterns:**

Use `go_router`.

Canonical routes:

```text
/pair
/field
/field/:id
/demo
/settings
```

Route redirects:

- No saved device and not in Demo Mode -> `/pair`
- Saved device or Demo Mode active -> `/field`
- Change Device clears saved connection and returns to `/pair`

### Process Patterns

**Error Handling Patterns:**

Separate developer errors from user-facing messages.

Repository/Cubit layers may log technical details. UI copy must be farmer/evaluator-friendly:

- `We could not find that device code.`
- `No recent reading from the device.`
- `The reading may be outdated.`
- `Demo data is being shown.`

Avoid user-facing copy such as:

- `Permission denied`
- `Firebase exception`
- `Unauthorized`
- `Null snapshot`

**Loading and Empty State Patterns:**

Every RTDB-backed screen must handle:

- loading,
- no paired device,
- no data yet,
- live data,
- stale data,
- offline/error,
- malformed payload,
- demo data.

No screen may show a healthy/normal state until the trust-state resolver has enough valid data to justify it.

**Demo Mode Patterns:**

Demo Mode uses a separate repository or data source implementation behind the same UI contracts. It must not call RTDB and must not mutate paired-device state.

Demo Mode UI must include a persistent visible source marker such as `Demo Data`.

### Enforcement Guidelines

**All AI Agents MUST:**

- Use the canonical RTDB paths from the schema contract.
- Keep Firebase SDK imports out of UI and Cubits.
- Route all live data through repositories.
- Keep Demo Mode technically separate from live RTDB data.
- Use canonical enum-style values for `DataSource`, `TrustState`, and `FieldStatus`.
- Treat missing, stale, malformed, impossible, duplicate, and out-of-order telemetry as explicit states.
- Add tests for new Cubit state transitions and repository payload parsing.
- Update `docs/architecture/firebase-rtdb-schema.md` before changing RTDB paths or payload fields.
- Update `docs/runbooks/demo.md` before changing demo setup, firmware version, APK version, or fallback flow.

**Pattern Enforcement:**

- Static review: search for `firebase_database` imports outside allowed data/core Firebase files.
- Test review: every new feature with data state must include Cubit or repository tests.
- Fixture review: schema-changing work must update RTDB JSON fixtures.
- Runbook review: demo-critical changes must update the demo runbook.
- Architecture review: any new backend, Cloud Function, Firestore bridge, Laravel runtime API, or authentication change requires an architecture update before implementation.

### Pattern Examples

**Good Examples:**

```text
DashboardCubit subscribes to ReadingRepository.watchLatest(deviceCode).
ReadingRepository maps RTDB snapshots into ReadingResult.
FieldStatusPanel renders based on TrustState and FieldStatus.
DemoReadingRepository implements the same contract without RTDB calls.
```

**Anti-Patterns:**

```text
DashboardScreen imports firebase_database directly.
Flutter writes /devices/{deviceCode}/readings for live telemetry.
One widget treats missing data as normal.
Demo Mode writes sample readings into the live device path.
An agent adds a Laravel endpoint for telemetry without architecture approval.
An agent introduces /sensor_readings while firmware writes /devices/{deviceCode}/readings.
```
