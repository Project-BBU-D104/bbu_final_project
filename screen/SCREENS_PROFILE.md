# Profile

Profile itself is the Home tab (`frontend/lib/screen/profile/profile_screen.dart`) and is inventoried under Home so each screen has one group. This group contains account-edit flows opened from that tab.

## Edit profile — `frontend/lib/screen/profile/widget/edit_profile_widget.dart`
- **Route:** No named route; `ProfileController.openEditProfile` uses `AppFormShell`: dialog at widths of 840 logical pixels and above, bottom sheet below.
- **Purpose:** Updates the current user's profile information.
- **Navigation:** Profile tab Edit Profile button; Save, Cancel, Close or idle system back returns to Profile. Outside taps and sheet dragging are disabled.
- **UI:** Shared `ProfileFormLayout`, titled header/subtitle, scrollable form, `AppFormSection`, `AppFormField` and `AppFormActions`. Personal information contains Full Name and Photo URL; Contact details contains email and phone, paired only at an inner width of 560 or above.
- **State/data:** `ProfileController` prefills saved values, validates name/email, trims profile payloads, and preserves token, identity, role, active status and configuration. Phone/photo remain optional.
- **Interaction:** Submit validates and focuses/scrolls to the first error. Failed requests retain the draft. Saving disables fields and exit controls, blocks back and duplicate requests, and shows progress. Cancel/reopen restores saved data; only one account form opens at a time.

## Change password — `frontend/lib/screen/profile/widget/change_password_widget.dart`
- **Route:** No named route; `ProfileController.openChangePassword` uses the same adaptive shell and breakpoint.
- **Purpose:** Changes the current user's password.
- **Navigation:** Profile tab Change Password button; success, Cancel, Close or idle system back returns to Profile.
- **UI:** Shared account layout, Password section, minimum-length guidance and three stacked secure fields. Each field has an independent translated Show password/Hide password control. Fields start obscured, support paste and autofill, and disable autocorrection/suggestions.
- **State/data:** Current password is required; new password requires at least eight exact characters; confirmation must match exactly. Spaces are preserved. Only current/new passwords are sent. Errors retain the draft and login session. Every dismissal clears all password fields; reopening resets visibility.
- **Interaction:** Next focuses the next password field; Done and Update Password share guarded submission. Validation focuses/scrolls to the first error. Saving disables inputs, visibility controls and exits, blocks back/duplicate writes, and shows progress.

## Redesign notes

Both account forms use shared theme/tokens, English/Khmer translations and a single inset-aware scrolling layout. Titles/actions wrap for large text, and fields/errors/actions remain reachable with the keyboard open. Profile Home, uploads, backend endpoints and authentication policy are outside this redesign.
