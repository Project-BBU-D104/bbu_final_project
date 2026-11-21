# Audit (done)

Both Audit screens use the shared Flutter UI kit with English and Khmer labels, light and dark themes, and layouts that adapt to the available width and text size.

## Audit logs

- Route `/audit-logs`, opened from Manage → Audit Logs.
- Events appear newest first. Search matches titles, actions, users, tables, record and event IDs, and timestamps. Search and the action filter work together.
- Compact and large-text layouts use tappable cards. The wide layout uses a paginated table with a keyboard-accessible event link in each row.
- Loading, empty history, no matches, and failed requests have distinct feedback. Refresh and retry retain the search and action filter. Previously loaded events remain visible if refresh fails.
- Selecting an event opens its detail. The history is read-only.

## Audit event detail

- Route `/audit-log-detail`, opened with the selected event.
- The header identifies the event. The summary shows action, user, recorded time, table, and record ID.
- Recorded changes show before and after values side by side on wide layouts and stack them on compact layouts. Added and removed fields show which side is missing, and unchanged fields appear below changes.
- Create and delete events can display one recorded snapshot. Legacy plain-text values remain readable. Recorded content is selectable, and opening the route without an event shows an unavailable state.

## Verification

The 15 focused Audit and Manage access tests passed. They cover read-only navigation, combined filters, refresh and retry, desktop pagination, added and removed fields, and large-text layout in Khmer dark mode. Targeted analysis reported no diagnostics, and the standard Flutter web build passed. The build's WebAssembly dry run reported dependency warnings in `get_storage` and `image`.

Manual live API, browser, physical-device, and spoken screen-reader checks are pending.
