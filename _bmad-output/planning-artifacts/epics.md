---
stepsCompleted: [1, 2, 3]
inputDocuments:
  - C:\Users\LA\Documents\AppDev\AgriShield\_bmad-output\planning-artifacts\prds\prd-AgriShield-2026-05-21\prd.md
  - C:\Users\LA\Documents\AppDev\AgriShield\_bmad-output\planning-artifacts\architecture.md
  - C:\Users\LA\Documents\AppDev\AgriShield\_bmad-output\planning-artifacts\ux-design-specification.md
---

# AgriShield - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for AgriShield, decomposing the requirements from the PRD, UX Design if it exists, and Architecture requirements into implementable stories.

## Requirements Inventory

### Functional Requirements

- FR-1: User Registration
- FR-2: User Login
- FR-3: Latest Reading Display
- FR-4: Field Status Display
- FR-5: Device Status Display
- FR-6: Last Updated Timestamp
- FR-7: Latest Recommendation
- FR-8: Threshold-Based Classification
- FR-9: Severity Priority
- FR-10: Recommendation Mapping
- FR-11: Alert Creation or Display
- FR-12: Alert Details
- FR-13: Alert History
- FR-14: Alert Spam Prevention
- FR-15: Reading Storage
- FR-16: Reading History View
- FR-17: Simple Chart View
- FR-18: Sensor Explanation
- FR-19: Threshold and Status Explanation
- FR-20: Monitoring-Only Disclaimer
- FR-21: Simulated Reading Scenarios
- FR-22: Demo Data Separation
- FR-23: Project Explanation
- FR-24: Required Screen Set
- FR-25: Bottom Navigation

### NonFunctional Requirements

- NFR-1 (Usability): Farmers must understand status and recommendations without technical knowledge.
- NFR-2 (Reliability): Distinguish fresh data from delayed/missing; Demo mode backup.
- NFR-3 (Safety): Recommendations must be framed as field-check guidance, not automatic control or farming decisions.
- NFR-4 (Security): Authenticated users should access only the intended MVP demonstration data.
- NFR-5 (Maintainability): Thresholds and intervals must be easy to modify; business logic should be separated from UI.

### Additional Requirements

- Starter Template: We must use Very Good CLI Flutter Starter (`very_good create flutter_app mobile`). This directly impacts Epic 1, Story 1.
- Authentication Bypass: The MVP will use device-code pairing instead of Firebase Auth user registration/login.
- Backend Infrastructure: Use Firebase Realtime Database (RTDB) directly, without a custom Laravel API or Cloud Functions.
- State Management & Navigation: Use `flutter_bloc` (mostly Cubits) and `go_router`.
- Data Flow: ESP32 writes telemetry directly to Firebase RTDB; Flutter reads from RTDB through repository interfaces.

### UX Design Requirements

- UX-DR1: Implement "Apple Field Health" design direction (off-white backgrounds, large titles, rounded white cards).
- UX-DR2: Implement semantic tokens (status.okay, status.needsAttention, status.critical, confidence.recent, etc.) instead of hard-coded colors.
- UX-DR3: Implement FieldStatusCard to show status, main concern, confidence, last updated, and next check in one glance.
- UX-DR4: Implement offline/no-data visual states (gray/amber indicators, specific uncertainty copy).
- UX-DR5: Implement HealthScoreRing (circular score, status label, color thresholds).

### FR Coverage Map

- **FR-1:** Epic 1 - Handled via Device Pairing flow
- **FR-2:** Epic 1 - Handled via Device Pairing flow
- **FR-3:** Epic 2 - Latest reading values shown on Dashboard
- **FR-4:** Epic 2 - Overall Field Status calculation and display
- **FR-5:** Epic 2 - Device freshness/connection state
- **FR-6:** Epic 2 - Relative timestamp display
- **FR-7:** Epic 2 - Guidance derived from status
- **FR-8:** Epic 2 - Implementation of threshold logic
- **FR-9:** Epic 2 - Prioritizing Critical over Warning
- **FR-10:** Epic 2 - Mapping conditions to plain-language recommendations
- **FR-11:** Epic 3 - Alert trigger logic
- **FR-12:** Epic 3 - Individual alert details UI
- **FR-13:** Epic 3 - Alert list view
- **FR-14:** Epic 3 - Alert deduplication/cooldown
- **FR-15:** Epic 4 - Historical data storage logic in RTDB
- **FR-16:** Epic 4 - Reading history list view
- **FR-17:** Epic 4 - Simple trend charting
- **FR-18:** Epic 5 - Sensor explanation content
- **FR-19:** Epic 5 - Threshold/Status explanation content
- **FR-20:** Epic 5 - Disclaimer content
- **FR-21:** Epic 5 - Mock data generators
- **FR-22:** Epic 5 - Data source isolation for demo
- **FR-23:** Epic 5 - About Project screen
- **FR-24:** Epic 1 - Base screen scaffold and routes
- **FR-25:** Epic 1 - Bottom tab navigation setup

## Epic List

## Epic 1: App Foundation & Device Pairing

**User Outcome:** Users can launch the app, navigate its core structure, and securely pair with a field device to establish the monitoring connection.
**Implementation Notes:** This covers initializing the Very Good CLI Flutter starter, setting up the "Apple Field Health" UX tokens, and creating the device-pairing flow that bypasses traditional Firebase authentication.
**FRs covered:** FR-1, FR-2, FR-24, FR-25

### Story 1.1: App Scaffold & Design System Initialization

As a farmer,
I want a consistent, readable interface,
So that I can easily check my field conditions outdoors.

**Acceptance Criteria:**

**Given** the app is built from source
**When** the application launches
**Then** it uses the Very Good CLI project structure
**And** the "Apple Field Health" semantic design tokens (status colors, off-white backgrounds, typography) are properly configured in the Flutter Theme
**And** basic GoRouter navigation is established

### Story 1.2: Firebase RTDB & Device Repository

As a farmer,
I want the app to connect securely to the database,
So that it can retrieve my field's readings.

**Acceptance Criteria:**

**Given** the app has internet access
**When** the app is initialized
**Then** it successfully connects to the Firebase Realtime Database
**And** a base `DeviceConnectionRepository` is available for managing device configurations

### Story 1.3: Device Pairing Flow

As a farmer,
I want to pair my app with my field device using a simple code,
So that I don't have to create an account or remember a password.

**Acceptance Criteria:**

**Given** I am a first-time or unpaired user
**When** I open the app
**Then** I am routed to the Device Pairing screen
**And Given** I enter a valid device code
**When** I submit the code
**Then** the app saves the pairing locally and routes me to the main app shell
**And Given** I am an already-paired user
**When** I reopen the app
**Then** I bypass the pairing screen and go straight to the Dashboard

### Story 1.4: Main Tab Navigation

As a farmer,
I want simple tabs at the bottom of the screen,
So that I can switch between my field dashboard, alerts, and history easily.

**Acceptance Criteria:**

**Given** I am a paired user
**When** I am viewing the main app shell
**Then** I see bottom navigation tabs for Dashboard, Alerts, History, and More
**And** tapping each tab correctly routes me to the corresponding placeholder screen

## Epic 2: Live Field Dashboard

**User Outcome:** Farmers can open the app and instantly see their field's current condition, trust level (freshness), and what physical action to take next, without needing to interpret raw sensor data.
**Implementation Notes:** This focuses on the one-glance Dashboard check, implementing the `FieldStatusCard`, `HealthScoreRing`, threshold classifications, and offline/stale data states. It connects to the Firebase RTDB latest readings.
**FRs covered:** FR-3, FR-4, FR-5, FR-6, FR-7, FR-8, FR-9, FR-10

### Story 2.1: Live Telemetry Repository

As a farmer,
I want the app to listen for the latest sensor readings from my field,
So that my dashboard can display real-time data.

**Acceptance Criteria:**

**Given** the app is connected to a paired device
**When** the ESP32 writes a new reading to Firebase RTDB (`/latest`)
**Then** the repository receives the update and parses it into a strongly-typed domain model
**And** malformed or incomplete data is handled safely without crashing

### Story 2.2: Threshold Classification & Trust Logic

As a farmer,
I want the app to automatically classify readings into Normal, Warning, or Critical states,
So that I don't have to interpret raw sensor numbers myself.

**Acceptance Criteria:**

**Given** a new reading is received
**When** it is evaluated against the defined threshold rules
**Then** the Field Status is correctly classified (Critical taking priority over Warning)
**And** the appropriate plain-language recommendation is mapped to the condition
**And When** a reading is older than the freshness threshold or missing entirely
**Then** the Trust State resolves to Stale, Offline, or No Data accordingly

### Story 2.3: Dashboard State Management

As a farmer,
I want the dashboard to update smoothly as conditions change,
So that I always see the most accurate field status without having to manually refresh.

**Acceptance Criteria:**

**Given** the dashboard is active
**When** the repository emits a new reading or the trust state changes
**Then** the Dashboard Cubit updates the UI state immediately
**And** the state clearly exposes the `FieldStatus`, `TrustState`, and `Recommendation` for the UI to consume

### Story 2.4: Field Status & Health Score UI

As a farmer,
I want to see a clear field health score and recommendation at a glance,
So that I immediately know if I need to check the field.

**Acceptance Criteria:**

**Given** I am on the Dashboard
**When** the field status is Normal, Warning, or Critical
**Then** the `FieldStatusCard` displays the appropriate semantic color, icon, and `HealthScoreRing`
**And** the app displays a clear, plain-language physical recommendation (e.g., "Check water level")
**And When** the data is Stale or Offline
**Then** the UI shows appropriate uncertainty indicators (gray/amber) instead of a false "healthy" green

### Story 2.5: Sensor Details & Freshness UI

As a farmer,
I want to see the specific sensor values and exactly when they were updated,
So that I have the context behind the field status.

**Acceptance Criteria:**

**Given** I am on the Dashboard
**When** I look below the main status card
**Then** I see individual compact cards for Soil Moisture, Water Level, Temperature, and Humidity
**And** I clearly see the "Last Updated" timestamp in a readable format (e.g., "Updated 5 min ago")
**And** missing or invalid sensor values display a safe fallback (e.g., "--" instead of incorrectly showing "0")

## Epic 3: Field Alerts & Notifications

**User Outcome:** Farmers are clearly alerted to abnormal field conditions (Warnings/Critical) and can review details to understand the concern and take action.
**Implementation Notes:** This includes evaluating the thresholds over time, creating alerts without spamming the user, and providing the Alert Details and Alert History screens.
**FRs covered:** FR-11, FR-12, FR-13, FR-14

### Story 3.1: Alert Generation & Deduplication Logic

As a farmer,
I want the app to generate an alert when conditions become concerning, but I don't want to be spammed with duplicates,
So that I know when to act without being overwhelmed by notifications.

**Acceptance Criteria:**

**Given** the app detects a new Warning or Critical field status
**When** the status is a new change OR the defined cooldown period has passed
**Then** a new Alert record is generated
**And** multiple readings of the exact same status within the cooldown period do NOT create duplicate alerts

### Story 3.2: Alert List UI

As a farmer,
I want to see a chronological list of recent alerts,
So that I can review what field issues have happened over time.

**Acceptance Criteria:**

**Given** I have navigated to the Alerts tab
**When** I view the screen
**Then** I see a list of Alerts sorted by newest first
**And** each list item clearly shows the severity (Warning vs Critical), the relative timestamp, and a brief description
**And** there is a friendly empty state if no alerts exist

### Story 3.3: Alert Detail Screen

As a farmer,
I want to see the specific details of an alert,
So that I understand exactly what caused it and what physical check I should perform.

**Acceptance Criteria:**

**Given** I am viewing the Alert List or an active alert on the Dashboard
**When** I tap on an Alert
**Then** I am navigated to the Alert Detail screen
**And** I see the affected sensor, severity, exact timestamp, the reading value, the threshold context, and the recommended plain-language action

## Epic 4: Historical Trends & Analytics

**User Outcome:** Farmers can review past sensor readings and simple charts to see if conditions are worsening, improving, or remaining stable over time.
**Implementation Notes:** Connects to the historical Firebase RTDB paths, presenting historical data in a simple, farmer-friendly chart view.
**FRs covered:** FR-15, FR-16, FR-17

### Story 4.1: Reading History Repository & Logic

As a farmer,
I want the app to securely fetch historical readings from Firebase,
So that I can review past conditions without the app freezing.

**Acceptance Criteria:**

**Given** the app is connected and paired
**When** the user requests historical data
**Then** the repository fetches the historical readings from the correct Firebase RTDB path (`/devices/{deviceCode}/readings/{readingId}`)
**And** the readings are correctly sorted chronologically
**And** queries are limited so they don't perform unbounded scans of the entire database

### Story 4.2: Historical List View

As a farmer,
I want to see a list of past sensor readings,
So that I can verify field conditions from earlier today or yesterday.

**Acceptance Criteria:**

**Given** I am on the History tab
**When** I view the screen
**Then** I see a chronological list of past readings
**And** each item shows a compact summary of the sensor values and the exact timestamp
**And** there is a clear, friendly empty state if no history exists yet

### Story 4.3: Simple Trend Chart

As a farmer,
I want to see a simple visual chart of my field conditions,
So that I can quickly spot trends like dropping water levels or rising temperatures.

**Acceptance Criteria:**

**Given** I am on the History tab
**When** I look at the chart section
**Then** I see a basic, readable chart showing the trend of the sensors over time
**And** the chart displays cleanly on mobile screens without requiring technical analytics knowledge

## Epic 5: Demo Mode & Educational Guides

**User Outcome:** Evaluators and farmers can safely simulate conditions without live sensors, and learn how to interpret the prototype's guidance while understanding its "monitoring-only" limitations.
**Implementation Notes:** Explicitly separates simulated data from real sensor data and adds the Guide, Project Explanation, and Threshold Info screens.
**FRs covered:** FR-18, FR-19, FR-20, FR-21, FR-22, FR-23

### Story 5.1: Demo Data Separation & Mock Repository

As an evaluator,
I want a separate Demo Mode that supplies realistic simulated readings,
So that I can test the app even when real sensors are disconnected or offline.

**Acceptance Criteria:**

**Given** I have enabled Demo Mode from the Settings/More tab
**When** the app requests live or historical readings
**Then** it switches to a mock repository that supplies simulated Normal, Warning, and Critical scenarios
**And** real telemetry is never overwritten or mixed with demo data

### Story 5.2: Educational Guide & Threshold Info

As a farmer,
I want the app to explain what the sensors mean and how the thresholds work,
So that I understand how the app is classifying my field.

**Acceptance Criteria:**

**Given** I am on the More tab
**When** I tap "Guide & Thresholds"
**Then** I see a screen explaining the sensors (soil moisture, water level, etc.) in plain language
**And** the screen clearly lists the prototype threshold boundaries (e.g., Soil Moisture < 30% is Critical)

### Story 5.3: Project Disclaimer & Information

As an evaluator or farmer,
I want to clearly understand the scope and limitations of the app,
So that I know it's a monitoring prototype and not an automatic irrigation controller.

**Acceptance Criteria:**

**Given** I am on the More tab
**When** I tap "About Project"
**Then** I see the project purpose, the explicit monitoring-only safety disclaimer, and the technologies used
