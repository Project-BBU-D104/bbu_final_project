# Profile

Profile itself is the Home tab (`frontend/lib/screen/profile/profile_screen.dart`) and is inventoried under Home so each screen has one group. This group contains account-edit flows opened from that tab.

## Edit profile — `frontend/lib/screen/profile/widget/edit_profile_widget.dart`
- **Route:** No named route; opened through `ProfileController.openEditProfile`; host presentation details unclear.
- **Purpose:** Updates the current user’s profile information.
- **Navigation:** Profile tab Edit Profile button; save/cancel returns to profile.
- **UI:** Prefilled profile form and actions.
- **State/data:** `ProfileController`, profile service and current user data.
- **Custom widgets:** None established.
- **Current design issues:** Host constraints and exact theme issues unclear.

## Change password — `frontend/lib/screen/profile/widget/change_password_widget.dart`
- **Route:** No named route; opened through `ProfileController.openChangePassword`; host presentation details unclear.
- **Purpose:** Changes the current user’s password.
- **Navigation:** Profile tab Change Password button; success/cancel returns to profile.
- **UI:** Password fields, submit/cancel actions.
- **State/data:** `ProfileController`, profile/auth service.
- **Custom widgets:** None established.
- **Current design issues:** Sensitive-field usability and host constraints need review; specific defect unclear.

## Redesign notes

