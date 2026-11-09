# Auth

## Landing — `frontend/lib/screen/landing.dart`
- **Route:** `/landing`
- **Purpose:** Displays the startup/loading page while choosing the next app route.
- **Navigation:** App initial route; `LandingController` sends the user to stored startup route or `/login`. Next: Login or Home/remembered route.
- **UI:** Scaffold and startup content; exact elements unclear from inventory scan.
- **State/data:** `LandingController`, storage startup preference.
- **Custom widgets:** None established.
- **Current design issues:** Specific issues unclear; check against `AppTheme` during redesign.

## Login — `frontend/lib/screen/auth/login_screen.dart`
- **Route:** `/login`
- **Purpose:** Lets the user enter credentials and sign in.
- **Navigation:** From Landing or logout/session expiry; successful login goes to `/home`.
- **UI:** Scaffold, login inputs and submit action.
- **State/data:** `LoginController`, `AuthService`, credential and session state.
- **Custom widgets:** `frontend/lib/screen/auth/widget/input_login_widget.dart`.
- **Current design issues:** Specific hardcoded styling/layout issues unclear from route scan.

## Redesign notes

