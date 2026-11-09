# Audit

## Audit logs — `frontend/lib/screen/audit_logs/audit_logs_screen.dart`
- **Route:** `/audit-logs`
- **Purpose:** Browses audit history.
- **Navigation:** Manage → Audit Logs; selecting an event opens detail.
- **UI:** Search/list cards and selection action.
- **State/data:** `AuditLogController`, `AuditLogsBinding`, audit log service/model.
- **Custom widgets:** `screen/audit_logs/widget/audit_card_widget.dart`, detail widget.
- **Current design issues:** Specific layout/theme issues unclear.

## Audit log detail — `frontend/lib/screen/audit_logs/widget/audit_log_detail_widget.dart`
- **Route:** `/audit-log-detail`, selected event argument.
- **Purpose:** Reviews the fields recorded for one audit event.
- **Navigation:** Audit list selection; back returns to list.
- **UI:** Scaffold with structured detail content.
- **State/data:** Audit log argument/model.
- **Custom widgets:** `audit_card_widget.dart`, shared app bar if used.
- **Current design issues:** Dense detail layout may need responsive review; exact defect unclear.

## Redesign notes

