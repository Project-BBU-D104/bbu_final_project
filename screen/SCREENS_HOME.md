# Home

**Status: Done for all six screens:** Home shell, Home content, Dashboard, Manage, Report index, and Profile. Implementation, automated regression checks, and the standard web build are complete. Manual live-browser, physical-device, and screen-reader checks remain pending.

## Home shell — `frontend/lib/screen/home/home_screen.dart`
- **Route:** `/home`
- **Purpose:** Provides responsive navigation among the app’s primary sections.
- **Navigation:** Login success or startup route; tabs open Home content, Dashboard, Manage, Report (role-gated), and Profile.
- **UI:** Scaffold and `PageView`; app-level persistent desktop NavigationRail and mobile NavigationBar on Home. The desktop sidebar shows the app logo at the top and Profile at the bottom.
- **State/data:** `HomeController`, `HomeBinding`, selected tab, role data.
- **Custom widgets:** App-level `desktop_app_shell.dart` and the tab pages listed below.
- **Redesign status:** Done. Theme-aware navigation persists across feature and detail routes, including direct page pushes. Sign-in and startup remain outside the sidebar.

## Home content — `frontend/lib/screen/home/home_content.dart`
- **Route:** Embedded Home tab; none.
- **Purpose:** Shows welcome context, recent purchases/sales, and shortcuts.
- **Navigation:** Home shell tab; quick actions and recent activity navigate into features. Next destinations include `/category`, `/product`, `/supplier`, `/sale`, `/sale-list`, `/purchase`.
- **UI:** Responsive scrollable layout, welcome card with New sale action, quick-action cards, and recent sales/purchases with loading, empty, error, and retry states.
- **State/data:** `HomeController`; `HomeService` recent sales/purchases; stored login user data.
- **Custom widgets:** Shared `home_tab_layout.dart`, `welcome_widget.dart`, `quick_action_widget.dart`, `recent_sale_widget.dart`, `recent_purchase_order_widget.dart`, and `recent_orders_widget.dart`.
- **Redesign status:** Done. Supports light/dark themes, Khmer, and enlarged text.

## Dashboard — `frontend/lib/screen/dashboard/dashboard_screen.dart`
- **Route:** Embedded Home tab; none.
- **Purpose:** Reviews inventory KPIs, movement, category revenue, low stock, and top products.
- **Navigation:** Home shell tab; refresh reloads dashboard data. Next navigation from individual components is unclear.
- **UI:** Shared page header with refresh action, responsive KPI cards, themed monthly-sales and category-revenue charts, low-stock alerts, ranked products, and loading/error/empty states. Wide screens use multiple columns; phones stack the cards.
- **State/data:** `DashboardController`, dashboard service; KPI, monthly sales, revenue-by-category, low-stock and top-product data.
- **Custom widgets:** `screen/dashboard/widget/card_kpi_widget.dart`, `stock_in_chart_widget.dart`, `category_revenue_widget.dart`, `low_stock_widget.dart`, `top_proudct_widget.dart`.
- **Redesign status:** Done. Uses theme-aware surfaces and typography, translated labels, chart data semantics, reduced-motion support, safe error feedback, and retry. Removed hard-coded dollar symbols; values retain the amounts recorded by the API.

## Manage — `frontend/lib/screen/manage/manage_screen.dart`
- **Route:** Embedded Home tab; none.
- **Purpose:** Searches and opens management sections available to the current role.
- **Navigation:** Home shell tab; feature cards go to their named routes. Next: catalog, stock, purchases, sales, people, configuration, audit.
- **UI:** Shared page header, labeled search field, responsive feature cards with meaningful icons and navigation arrows, translated section headings, and a clearable no-results state.
- **State/data:** `ManageController`, independently tagged `SearchFeatureController`, stored current role and role access map. Existing role restrictions are preserved.
- **Custom widgets:** Shared `home_tab_layout.dart`, `feature_directory_widget.dart`, `search_feature_widget.dart`, and `card_feature_widget.dart`.
- **Redesign status:** Done. Cards wrap long and enlarged labels, adapt to available width, and support light/dark themes. Search is independent from the Report tab.

## Report index — `frontend/lib/screen/report/report_screen.dart`
- **Route:** Embedded Home tab; none.
- **Purpose:** Searches and opens report pages.
- **Navigation:** Home shell tab, shown only when `HomeController.canViewReport`; cards route to six reports.
- **UI:** Shared page header, labeled search, translated section headings, and responsive cards for all six report destinations. Includes a clearable no-results state.
- **State/data:** `ReportController`, independently tagged `SearchFeatureController`; static report definitions.
- **Custom widgets:** Shared `home_tab_layout.dart`, `feature_directory_widget.dart`, `search_feature_widget.dart`, and `card_feature_widget.dart`.
- **Redesign status:** Done. Matches Manage's directory layout, uses report-specific icons, supports Khmer and dark mode, and keeps report searching independent from Manage.

## Profile tab — `frontend/lib/screen/profile/profile_screen.dart`
- **Route:** Embedded Home tab; none.
- **Purpose:** Reviews profile information, opens account settings, and logs out.
- **Navigation:** Home shell tab; edit/password actions open profile flows, logout returns to login.
- **UI:** Responsive account summary, selectable personal information, edit/password actions, preferences, and a separate account-access card. Wide screens use two columns; phones stack the panels. Avatar loading and errors use a static fallback.
- **State/data:** `ProfileController`, stored/current user and profile service.
- **Custom widgets:** `screen/profile/widget/card_profile_widget.dart`, `card_personal_info_widget.dart`, `setting_widget.dart`.
- **Redesign status:** Done. Uses shared themed cards, wrapping action buttons, theme-based logout styling, an accessible dark-mode switch, and a redesigned language dialog. Existing profile edit, password, and logout flows remain functional.

## Redesign notes

- Validation: all 172 Flutter tests passed. Targeted analysis of edited widgets, controllers, translations, and tests reports no issues.
- Web validation: `flutter build web --no-pub --no-wasm-dry-run` passed. The optional WebAssembly compatibility check was skipped after its compiler stalled; the standard web target was built successfully.
- Full-group tests cover all five real tabs together inside the Home shell, all six report destinations, independent searches, clearing filters, refresh/retry/empty states, profile actions, logout, language switching, and Khmer Unicode integrity. Existing navigation and role-access regression tests also pass.
- Layout checks cover small phones, desktop, landscape, both themes, and Khmer at 200% text size. Desktop and phone previews were rendered and visually reviewed, including dark-mode charts and enlarged Khmer text.
- Dashboard amounts have no currency metadata in the current API, so the UI displays recorded amounts without a currency symbol or conversion.
- Manual live-browser, physical-device, and screen-reader checks remain pending.

