# Auth

**Status: Done** (implementation completed 2026-11-09). Automated validation passed; physical-device, screen-reader, and password-manager checks remain pending.

## Landing — `frontend/lib/screen/landing.dart`
- **Route:** `/landing`
- **Purpose:** Displays the startup/loading page while choosing the next app route.
- **Navigation:** App initial route; `LandingController` sends the user to stored startup route or `/login`. Next: Login or Home/remembered route.
- **UI:** Centered branded splash — logo badge, app name, localized tagline, indeterminate progress bar. Responsive logo/padding via `LayoutBuilder`.
- **State/data:** `LandingController`, storage startup preference.
- **Custom widgets:** None (self-contained).
- **Current design issues:** Resolved — hardcoded Khmer-only copy, light-only fixed gradient, no loading feedback.

## Login — `frontend/lib/screen/auth/login_screen.dart`
- **Route:** `/login`
- **Purpose:** Lets the user enter credentials and sign in.
- **Navigation:** From Landing or logout/session expiry; successful login goes to `/home`.
- **UI:** Responsive layout. At ≥900px: split screen with gradient brand panel and elevated form card. Below 900px: compact gradient header plus form card. Labeled fields, inline validation, password visibility toggle, loading spinner.
- **State/data:** `LoginController`, `AuthService`, credential and session state.
- **Custom widgets:** `frontend/lib/screen/auth/widget/input_login_widget.dart`.
- **Current design issues:** Resolved — fixed 180px spacer, placeholder-only inputs, hardcoded white sheet that broke in dark mode, unused `Get.find` in the input widget.

## Redesign notes

Redesigned 2026-11-09 (UI/UX Pro Max: Minimalism/Swiss, trust-blue theme).

- Both screens read from `Theme.of(context).colorScheme`; light/dark mode now applies automatically.
- Single breakpoint at 900px via `LayoutBuilder`; form is capped at 420px so it does not stretch on web.
- Login uses `Form` + `TextFormField` validators (inline errors), autofill hints, and keyboard submit (`next` / `done`).
- Auth copy added to `en_us.dart` and `km_kh.dart`.
- Not included: forgot-password link (no backend flow) and a language/theme switch on login (both available after sign-in).

