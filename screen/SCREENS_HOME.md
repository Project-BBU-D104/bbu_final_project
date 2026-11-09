# Home

**Status: Done** for the Home content tab and navigation shell, including the persistent desktop sidebar, app logo, and bottom Profile action. Dashboard, Manage, Report, and Profile tab redesigns remain pending.

## Home shell — `frontend/lib/screen/home/home_screen.dart`
- **Route:** `/home`
- **Purpose:** Provides responsive navigation among the app’s primary sections.
- **Navigation:** Login success or startup route; tabs open Home content, Dashboard, Manage, Report (role-gated), and Profile.
- **UI:** Scaffold and `PageView`; app-level persistent desktop NavigationRail and mobile NavigationBar on Home. The desktop sidebar shows the app logo at the top and Profile at the bottom.
- **State/data:** `HomeController`, `HomeBinding`, selected tab, role data.
- **Custom widgets:** Tab pages listed below.
- **Redesign status:** Done. Theme-aware navigation persists across feature and detail routes, including direct page pushes. Sign-in and startup remain outside the sidebar.

## Home content — `frontend/lib/screen/home/home_content.dart`
- **Route:** Embedded Home tab; none.
- **Purpose:** Shows welcome context, recent purchases/sales, and shortcuts.
- **Navigation:** Home shell tab; quick actions and recent activity navigate into features. Next destinations include `/category`, `/product`, `/supplier`, `/sale`, `/sale-list`, `/purchase`.
- **UI:** Responsive scrollable layout, welcome card with New sale action, quick-action cards, and recent sales/purchases with loading, empty, error, and retry states.
- **State/data:** `HomeController`; `HomeService` recent sales/purchases; stored login user data.
- **Custom widgets:** `screen/home/widget/welcome_widget.dart`, `quick_action_widget.dart`, `recent_sale_widget.dart`, `recent_purchase_order_widget.dart`.
- **Redesign status:** Done. Supports light/dark themes, Khmer, and enlarged text.

## Dashboard — `frontend/lib/screen/dashboard/dashboard_screen.dart`
- **Route:** Embedded Home tab; none.
- **Purpose:** Reviews inventory KPIs, movement, category revenue, low stock, and top products.
- **Navigation:** Home shell tab; refresh reloads dashboard data. Next navigation from individual components is unclear.
- **UI:** RefreshIndicator, KPI cards, charts, ranked/alert lists, loading/error states.
- **State/data:** `DashboardController`, dashboard service; KPI, monthly sales, revenue-by-category, low-stock and top-product data.
- **Custom widgets:** `screen/dashboard/widget/card_kpi_widget.dart`, `stock_in_chart_widget.dart`, `category_revenue_widget.dart`, `low_stock_widget.dart`, `top_proudct_widget.dart`.
- **Current design issues:** Literal typography and spacing values; dashboard uses a hard-coded dollar symbol.

## Manage — `frontend/lib/screen/manage/manage_screen.dart`
- **Route:** Embedded Home tab; none.
- **Purpose:** Searches and opens management sections available to the current role.
- **Navigation:** Home shell tab; feature cards go to their named routes. Next: catalog, stock, purchases, sales, people, configuration, audit.
- **UI:** Search field and sectioned feature-card grid.
- **State/data:** `ManageController`, `SearchFeatureController`, stored current role and role access map.
- **Custom widgets:** `frontend/lib/widget/search_feature_widget.dart`, `frontend/lib/widget/card_feature_widget.dart`.
- **Current design issues:** Specific layout/style issues unclear.

## Report index — `frontend/lib/screen/report/report_screen.dart`
- **Route:** Embedded Home tab; none.
- **Purpose:** Searches and opens report pages.
- **Navigation:** Home shell tab, shown only when `HomeController.canViewReport`; cards route to six reports.
- **UI:** Custom app bar, search, section headings and responsive card grids.
- **State/data:** `ReportController`, `SearchFeatureController`; static report definitions.
- **Custom widgets:** `frontend/lib/widget/custom_app_bar.dart`, `search_feature_widget.dart`, `card_feature_widget.dart`.
- **Current design issues:** Literal text style and spacing values; source has garbled comments/encoding in this file.

## Profile tab — `frontend/lib/screen/profile/profile_screen.dart`
- **Route:** Embedded Home tab; none.
- **Purpose:** Reviews profile information, opens account settings, and logs out.
- **Navigation:** Home shell tab; edit/password actions open profile flows, logout returns to login.
- **UI:** Profile and personal-information cards, buttons, settings, logout.
- **State/data:** `ProfileController`, stored/current user and profile service.
- **Custom widgets:** `screen/profile/widget/card_profile_widget.dart`, `card_personal_info_widget.dart`, `setting_widget.dart`.
- **Current design issues:** Logout uses explicit colors and several literal spacing values.

## Redesign notes

- Validation: all 150 Flutter tests and `flutter build web --no-pub` passed.
- Navigation tests cover sidebar persistence, named and direct routes, dialogs, back navigation, resizing without losing draft text, role-gated reports, and Profile placement.
- Live-browser testing remains pending. Analysis reports the existing Supabase `anonKey` deprecation notice.

