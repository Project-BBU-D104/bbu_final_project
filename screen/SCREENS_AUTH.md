# Auth

**Status: Implementation complete; manual QA pending.** Startup and sign-in implementation, automated tests, and Chrome accessibility/autofill checks are complete. Physical-device, real screen-reader, and password-manager save/retrieval checks remain pending.

## Landing — `frontend/lib/screen/landing.dart`
- **Route:** `/landing`
- **Purpose:** Displays the startup/loading page while choosing the next app route.
- **Navigation:** App initial route; `LandingController` sends the user to stored startup route or `/login`. Next: Login or Home/remembered route.
- **UI:** Scrollable centered splash with an 80px logo, app name, localized tagline, and loading indicator. Startup failures show a safe message and Retry action.
- **State/data:** `LandingController`, storage startup preference.
- **Custom widgets:** None (self-contained).
- **Current design issues:** Resolved — hardcoded Khmer-only copy, light-only styling, no loading feedback. The app name is a semantic heading; loading has one accessible announcement instead of duplicate indicator/text labels.

## Login — `frontend/lib/screen/auth/login_screen.dart`
- **Route:** `/login`
- **Purpose:** Lets the user enter credentials and sign in.
- **Navigation:** From Landing or logout/session expiry; successful login goes to `/home`.
- **UI:** At ≥900px, a solid themed brand panel sits beside a bordered sign-in form. Smaller layouts show compact branding above the form; below 600px, the form uses the page surface. Content is capped at 440px. Includes language/theme controls, labeled fields, inline validation, password visibility, recovery guidance, and a loading state.
- **State/data:** `LoginController`, `AuthService`, credential and session state.
- **Custom widgets:** `frontend/lib/screen/auth/widget/input_login_widget.dart` and the shared language-selection dialog.
- **Current design issues:** Resolved — fixed spacer, placeholder-only inputs, light-only surfaces, missing pre-sign-in preferences, missing password-recovery guidance, and missing toggle-state semantics. Credentials cannot be edited while a sign-in request is pending.

## Redesign notes

Redesigned 2026-11-09 (UI/UX Pro Max: Minimalism/Swiss, trust-blue theme).

- Both screens read from `Theme.of(context).colorScheme`; light/dark mode now applies automatically.
- `LayoutBuilder` uses a 900px split-layout breakpoint and 600px compact-form breakpoint; content is capped at 440px.
- Login uses `Form` + `TextFormField` validators (inline errors), autofill hints, and keyboard submit (`next` / `done`).
- Auth copy added to `en_us.dart` and `km_kh.dart`.
- Language and theme controls are available before sign-in, reuse the existing controllers, persist preferences, and preserve typed credentials while switching.
- Forgot password opens guidance for the existing administrator reset flow in User Management. Self-service email/token password recovery is not implemented because the backend has no recovery endpoint.
- Username/password autofill hints, native paste, keyboard Next/Done, password visibility, and explicit autofill-context commit on successful sign-in are covered by tests. Failed sign-in does not commit credentials to autofill.
- `web/auth_autofill.js` preserves the known username/current-password autocomplete hints that the current Flutter web semantics editor otherwise overwrites. It does not read credential values or modify unrelated fields. The source includes the condition for removing this compatibility fix after an SDK update.
- Browser page and shortcut titles now match InventoryFlow branding.

## Validation

- `flutter test --no-pub`: all 180 tests passed.
- `node --test test/auth_autofill_test.mjs`: both web-autofill compatibility tests passed.
- Targeted Flutter analysis of auth widgets, translations, and tests: no issues.
- `flutter build web --no-pub --no-wasm-dry-run`: passed. The optional Wasm compatibility dry run was skipped; this validates the standard web target.
- Headless Chrome against the built app, with accessibility enabled: verified control names and roles, username/current-password autocomplete attributes, password visibility, recovery dialog, English/Khmer switching, theme switching, retained credentials, and persisted preferences after reload. Only synthetic input was used; no credentials were submitted to the backend.
- Automated accessibility checks cover control names, semantic headings, minimum touch targets, keyboard traversal, and light/dark semantic color contrast. Responsive checks cover English/Khmer at 200% text, phone/tablet/desktop/landscape sizes, and simulated keyboard insets.

## Remaining manual checks

- Physical Android/iOS devices: native keyboard, safe areas, scrolling to Sign in, and OS autofill integration.
- NVDA, VoiceOver, or TalkBack: spoken loading/errors, focus order, field labels, and password-visibility state. Chrome's accessibility tree was checked; spoken screen-reader behavior has not been verified.
- A real browser/OS password manager with an authorized test account: save credentials after successful HTTPS sign-in, retrieve them later, and confirm failed sign-in never triggers saving. Platform hints and autofill commit/cancel behavior are tested, but real password-manager storage/retrieval is not.

