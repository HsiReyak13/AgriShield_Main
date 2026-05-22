# Epic 5 Context: Demo Mode & Educational Guides

<!-- Compiled from planning artifacts. Edit freely. Regenerate with compile-epic-context if planning docs change. -->

## Goal

Evaluators and farmers can safely simulate conditions without live sensors, and learn how to interpret the prototype's guidance while understanding its "monitoring-only" limitations. This epic ensures safe evaluation by separating demo data from live data and explaining the sensor meaning and system thresholds.

## Stories

- Story 5.1: Demo Data Separation & Mock Repository
- Story 5.2: Educational Guide & Threshold Info
- Story 5.3: Project Disclaimer & Information

## Requirements & Constraints

- A Demo Mode must be available as a presentation backup when hardware or Wi-Fi is unavailable.
- Simulated scenarios must be clearly separated from live data; real telemetry must never be overwritten by demo data.
- The app must present educational content explaining sensors, thresholds, and health classifications.
- A mandatory project disclaimer must explicitly state that the app provides monitoring only and is not an automatic irrigation controller.

## Technical Decisions

- Demo Mode uses a separate data provider/repository but the same UI contracts.
- The UI must distinguish paired live data from Demo Mode, using persistent indicators if Demo Mode is active.
- Settings/More tab handles the toggle for Demo Mode and navigation to the educational and disclaimer screens.

## UX & Interaction Patterns

- "More" or "Settings" tab in the bottom navigation serves as the entry point for the Demo Mode toggle, Guide, and Project Disclaimer screens.
