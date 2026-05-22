# Story 1.1: App Scaffold & Design System Initialization

Status: ready-for-dev

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a farmer,
I want a consistent, readable interface,
so that I can easily check my field conditions outdoors.

## Acceptance Criteria

1. Given the app is built from source, when the application launches, then it uses the agreed Flutter app foundation and a feature-oriented structure aligned with the Very Good CLI architecture.
2. Given the application launches, then the "Apple Field Health" / AgriShield Field Material semantic design tokens are configured in Flutter Theme code instead of scattered hard-coded values.
3. Given the application launches, then status, confidence, surface, text, and border tokens are available for reuse by future Dashboard, Alerts, History, Demo Mode, and device-pairing work.
4. Given the app routes between startup and primary screens, then basic `go_router` navigation is established with a route map that supports the upcoming `/pair`, `/field`, `/field/:id`, `/demo`, and `/settings` flows.
5. Given the current repository already contains a Flutter prototype at `apps/mobile/`, then this story must not create a second duplicate Flutter app; it must either refactor the existing app in place or document any unavoidable structure variance before implementation proceeds.
6. Given the current prototype has an extensive single-file UI in `apps/mobile/lib/main.dart`, then reusable theme, routing, model, and shell concerns are split into maintainable files without breaking the current launch experience.
7. Given future stories add repositories, Cubits, Firebase, and device pairing, then the scaffold includes clear app/core/features boundaries so those additions have obvious homes.
8. Given the story is complete, then `flutter analyze` and `flutter test` pass from the Flutter app root.

## Tasks / Subtasks

- [ ] Confirm and document the Flutter runtime root before editing. (AC: 1, 5)
  - [ ] Treat `apps/mobile/` as the current Flutter app root because it contains `pubspec.yaml`, platform folders, `lib/main.dart`, and `test/widget_test.dart`.
  - [ ] Do not run `very_good create flutter_app` in a way that creates a parallel app unless architecture is explicitly revised first.
  - [ ] If the dev agent chooses to move toward `apps/mobile/`, preserve all existing Flutter work and update references consistently; do not leave two competing runtime apps.

- [ ] Reorganize app entry and shell code into a feature-oriented Flutter structure. (AC: 1, 6, 7)
  - [ ] Create `apps/mobile/lib/app/app.dart` for `AgriShieldApp`.
  - [ ] Create `apps/mobile/lib/app/router.dart` for `GoRouter` setup.
  - [ ] Create `apps/mobile/lib/app/theme/` for theme and token code.
  - [ ] Create `apps/mobile/lib/core/models/` for shared enums/value objects such as `TrustState`, `FieldStatus`, and `DataSource`.
  - [ ] Create `apps/mobile/lib/core/widgets/` for reusable presentation widgets that are not tied to one feature.
  - [ ] Create `apps/mobile/lib/features/dashboard/view/`, `features/alerts/view/`, `features/history/view/`, and `features/settings/view/` for current prototype screens.
  - [ ] Keep `apps/mobile/lib/main.dart` as a small bootstrap that calls `runApp(const AgriShieldApp())`.

- [ ] Add required foundation dependencies. (AC: 1, 4, 8)
  - [ ] Add `go_router` for navigation.
  - [ ] Add `flutter_bloc` for the state-management foundation; this story does not need full Cubit implementations unless required to keep the shell clean.
  - [ ] Consider `equatable` for future Cubit state objects if introduced in this story.
  - [ ] Keep dependency changes minimal; do not add Firebase packages in this story unless needed by generated starter code.

- [ ] Implement the AgriShield Field Material theme foundation. (AC: 2, 3)
  - [ ] Define semantic token classes or `ThemeExtension`s for field status, confidence, surfaces, text, border, and disabled states.
  - [ ] Include field status tokens: `status.okay`, `status.needsAttention`, `status.critical`.
  - [ ] Include confidence tokens: `confidence.recent`, `confidence.delayed`, `confidence.stale`, `confidence.noConnection`.
  - [ ] Include surface/text tokens: `surface.appBackground`, `surface.card`, `surface.statusCard`, `text.primary`, `text.secondary`, `text.helper`, `border.subtle`, `state.disabled`.
  - [ ] Preserve the current visual direction where useful: off-white background, white cards, strong green, amber, red, readable dark text, and subtle borders/shadows.
  - [ ] Use Material 3 theming through `ThemeData` and `ColorScheme`; avoid hard-coded status colors inside feature widgets when token access is available.

- [ ] Establish basic `go_router` navigation. (AC: 4)
  - [ ] Replace direct `MaterialApp(home: ...)` with `MaterialApp.router`.
  - [ ] Define at least these named routes: `/pair`, `/field`, `/field/:id`, `/demo`, and `/settings`.
  - [ ] Map the existing Home/Dashboard experience to `/field` for now.
  - [ ] Keep current visible tabs usable; if using an app shell, keep bottom navigation available while the user moves between field, alerts/history/settings placeholders or existing screens.
  - [ ] Do not implement full device pairing in this story; `/pair` can be a scaffold/placeholder compatible with Story 1.3.

- [ ] Preserve and improve the current prototype behavior during refactor. (AC: 6, 8)
  - [ ] Preserve the existing launchable AgriShield UI and trust-state demo behavior unless a change is required by the architecture.
  - [ ] Preserve current accessibility work such as semantic labels on trust pills and health score rings.
  - [ ] Remove or isolate demo/mock data in a way that future stories can replace it with repositories.
  - [ ] Avoid replacing the app with the default counter screen from a starter template.

- [ ] Add focused tests for scaffold integrity. (AC: 8)
  - [ ] Update `apps/mobile/test/widget_test.dart` so it pumps `AgriShieldApp` and verifies the app launches without exceptions.
  - [ ] Add a route smoke test or widget test proving the configured router can reach `/field` and `/settings`.
  - [ ] Add a token/theme test that verifies the semantic theme extension or token object is available from the app theme.
  - [ ] Run `flutter analyze` and `flutter test` from `apps/mobile/`.

## Dev Notes

### Current Repository State

- The repository already contains a Flutter app at `apps/mobile/` with `pubspec.yaml`, generated Android/iOS/Linux/macOS/web/windows folders, `analysis_options.yaml`, `lib/main.dart`, and `test/widget_test.dart`.
- `apps/mobile/lib/main.dart` currently contains the whole UI in one file: app bootstrap, theme constants, enums, mock data, shell, screens, widgets, and custom painters.
- The current `pubspec.yaml` only includes `flutter`, `cupertino_icons`, `flutter_test`, and `flutter_lints`; it does not yet include `go_router`, `flutter_bloc`, Very Good Analysis, generated flavor entrypoints, or a VGV-style folder split.
- The architecture document names `apps/mobile/` as the ideal runtime path, but the actual workspace has `apps/mobile/`. For this story, do not create a competing second runtime app. Refactor the existing `apps/mobile/` app unless the architecture is explicitly corrected first.
- There is only one existing commit: `6c0297d Initial AgriShield project architecture`. No previous story file exists, so there is no prior story intelligence to apply.

### Story Foundation

- Epic 1 outcome: users can launch the app, navigate its core structure, and pair with a field device later.
- Story 1.1 is the foundation story. It should create app structure, theme tokens, and basic navigation, not Firebase RTDB integration or device-code pairing behavior.
- FR coverage tied to Epic 1 includes device pairing/auth bypass and required screen/navigation structure. Full device pairing is Story 1.3; bottom tab navigation is Story 1.4.
- The PRD originally mentions Firebase Authentication, but the architecture overrides this for MVP: no Firebase Auth; device-code pairing replaces login/registration. Do not build login/register for this story.

### Architecture Compliance

- Primary runtime is a Flutter Android-first mobile app; the Laravel workspace is planning/docs/static artifacts only for the MVP.
- The selected architecture is Very Good CLI Flutter Starter in spirit: feature-oriented structure, Bloc/Cubit-friendly state management, tests, linting, and clear boundaries.
- Use `flutter_bloc` with mostly Cubits for future state management. Full Bloc is only for genuinely complex event sequencing.
- Use `go_router` for navigation. The architecture route map includes `/pair`, `/field`, `/field/:id`, `/demo`, and `/settings`.
- Keep Firebase imports out of UI and Cubits in later stories. This story should not introduce Firebase directly into views.
- Core model names to prepare for: `DataSource` with `live`, `demo`, `unknown`; `TrustState` with `noData`, `offline`, `stale`, `critical`, `warning`, `healthy`, `demo`, `loading`, `error`; `FieldStatus` with `normal`, `warning`, `critical`.
- Trust priority from architecture and UX: `No Data > Offline > Stale > Critical > Warning > Healthy`.
- New Flutter runtime code belongs under the Flutter app root. Because the actual root is `apps/mobile/`, apply the architecture folders under `apps/mobile/lib/` unless a repo structure migration is explicitly part of the dev implementation.

### UX Requirements

- The design foundation is AgriShield Field Material: Flutter Material components customized for farmer-facing field health, trust/freshness, alerts, and offline/no-data states.
- The Dashboard must prioritize meaning before numbers: current field condition, main concern, last updated time, and next field check come before raw sensor detail.
- Offline, stale, no-data, and connection states are first-class UX states, not small empty states.
- Important statuses must pair label + icon + color + explanation; never use color alone.
- Minimum tap target is `48x48 dp`; primary action height should be around `52-56 dp`.
- Home must remain usable at `320px` width, and bottom navigation must not cover CTAs, forms, banners, charts, or critical evidence.
- In stale/offline/no-data states, health score displays should say `Cannot verify` or show last-known status rather than implying current health.
- Outdoor readability matters: status labels should use strong contrast, and important freshness/source labels must not be tiny metadata.

### File Structure Requirements

Use this target structure for the current app root:

```text
apps/mobile/
  lib/
    main.dart
    app/
      app.dart
      router.dart
      theme/
        agri_theme.dart
        agri_tokens.dart
    core/
      models/
        data_source.dart
        field_status.dart
        trust_state.dart
      widgets/
    features/
      dashboard/
        view/
      alerts/
        view/
      history/
        view/
      settings/
        view/
      device_pairing/
        view/
      demo_mode/
        view/
  test/
```

Do not over-split every widget in the first pass if it creates churn. The minimum acceptable split is app bootstrap, router, theme/tokens, core models, and feature views. Shared widgets can move gradually as long as the current single-file concentration is reduced enough for future stories.

### Library / Framework Requirements

- Current local Dart SDK constraint is `^3.11.5` in `apps/mobile/pubspec.yaml`.
- `go_router` current pub.dev version observed on 2026-05-22 is `17.2.3`; it supports declarative routing, path/query parameters, redirection, and `ShellRoute` for persistent navigation shells. Use a compatible version with the local Flutter/Dart SDK.
- `flutter_bloc` integrates widgets with both Cubit and Bloc and is the architecture-approved state-management foundation. Use it where stateful architecture is introduced; do not force complex Bloc patterns into this scaffold story.
- Very Good CLI documentation says `very_good create flutter_app` generates a VGV-opinionated starter with Bloc, tests, linting, flavors, logging, and CI. Since an app already exists, borrow the structure/conventions rather than overwriting working project code.
- Flutter's `ThemeData.useMaterial3` is true by default in current Flutter documentation; keep Material 3 behavior and configure `ColorScheme`/theme extensions intentionally.

### Existing Code Guardrails

- Preserve launch behavior from `apps/mobile/lib/main.dart`: `AgriShieldApp` should still run and show the AgriShield UI, not a starter counter app.
- Preserve or improve current semantic labels on `TrustPill`, `HealthScoreRing`, and nav items.
- Preserve current mock/demo screens enough for visual continuity, but isolate mock data so Story 2+ can replace it with repository data.
- Existing `AppTab` has Home, Alerts, Advice, History, Settings, while the PRD says Dashboard, Alerts, History, More and the UX later mentions Home, Alerts, Advice, History, Settings. For this story, keep the existing tabs functional; Story 1.4 can finalize tab naming.
- Existing `TrustState` is missing `demo` and `error`; add those if moving the enum to `core/models/trust_state.dart`, even if UI handling remains placeholder.
- Existing theme colors are a good starting point, but hard-coded status colors should move into token/theme code.

### Testing Requirements

- Run from `apps/mobile/`:

```bash
flutter analyze
flutter test
```

- Tests should prove:
  - `AgriShieldApp` launches.
  - Router can render the main field route.
  - Theme tokens or extensions are accessible from the built app.
  - Existing trust-state UI still renders at least one healthy/default state.

### Scope Boundaries

- Do not implement Firebase RTDB, FlutterFire configuration, or ESP32 contracts in this story.
- Do not implement full device-code pairing persistence; only route scaffolding/placeholders are expected.
- Do not implement production authentication. Architecture says no Firebase Auth for the conceptual MVP.
- Do not build Laravel runtime endpoints or move MVP behavior into Laravel.
- Do not add SMS, AI recommendations, pest/disease detection, yield prediction, multi-farm support, or production hardening.

### Latest Technical References

- Very Good CLI `create flutter_app` docs: `https://cli.vgv.dev/docs/commands/create`
- Very Good Core template docs: `https://cli.vgv.dev/docs/templates/core`
- `go_router` package docs: `https://pub.dev/packages/go_router`
- `flutter_bloc` package docs: `https://pub.dev/packages/flutter_bloc`
- Flutter `ThemeData.useMaterial3` docs: `https://api.flutter.dev/flutter/material/ThemeData/useMaterial3.html`

### Project References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 1.1]
- [Source: _bmad-output/planning-artifacts/architecture.md#Selected Starter: Very Good CLI Flutter Starter]
- [Source: _bmad-output/planning-artifacts/architecture.md#Frontend Architecture]
- [Source: _bmad-output/planning-artifacts/architecture.md#Project Structure & Boundaries]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Design System Foundation]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Responsive Design & Accessibility]
- [Source: _bmad-output/planning-artifacts/prds/prd-AgriShield-2026-05-21/prd.md#Navigation and Screen Structure]
- [Source: apps/mobile/pubspec.yaml]
- [Source: apps/mobile/lib/main.dart]

## Dev Agent Record

### Agent Model Used

TBD by dev agent.

### Debug Log References

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created.

### File List
