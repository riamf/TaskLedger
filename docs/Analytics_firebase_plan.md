# TaskLedger — Firebase Analytics Tracking Plan

This document outlines the events and parameters required to track user behavior, feature adoption, and app health within TaskLedger, based on the established QA Test Plan.

---

## 1. Task Lifecycle & Creation
*Tracks how users set up their habits and identifies friction in the onboarding process.*

| Event Name | Parameters | Trigger |
| :--- | :--- | :--- |
| `task_created` | `task_type` (Counter, Cost, Income, Time), `frequency` (Daily, Weekly, Monthly, One-Time) | User taps "Save" on the Add Task sheet. |
| `task_creation_cancelled` | `step_reached` (Name, Type, Frequency) | User dismisses the Add Task sheet without saving. |
| `validation_error` | `error_type` (Missing Name, Zero Amount, No Days Selected) | User attempts to save while the button is disabled. |

---

## 2. Daily Engagement & Interactions
*Measures the core value loop of the app (completing daily tasks).*

| Event Name | Parameters | Trigger |
| :--- | :--- | :--- |
| `task_toggle` | `task_type`, `new_status` (Done, Undone) | User taps a task in the Day View. |
| `day_navigation` | `method` (Arrow, Calendar Picker), `direction` (Prev, Next) | User changes the viewed date. |
| `list_refreshed` | `view` (DayView, Summary) | User performs a pull-to-refresh. |

---

## 3. Financial & Time Analytics
*Tracks quantitative data for the specialized task types.*

| Event Name | Parameters | Trigger |
| :--- | :--- | :--- |
| `expense_logged` | `amount`, `task_name` | A "Cost" type task is marked as completed. |
| `income_logged` | `amount`, `task_name` | An "Income" type task is marked as completed. |
| `time_tracked` | `duration_minutes`, `task_name` | A "Time" type task is marked as completed. |

---

## 4. Retention & Management
*Tracks how users curate their lists over time.*

| Event Name | Parameters | Trigger |
| :--- | :--- | :--- |
| `task_snoozed` | `days_snoozed` | User confirms a snooze duration in the picker. |
| `task_archived` | `task_type` | User selects "Archive Schedule" (preserves history). |
| `task_fully_deleted` | `task_type` | User selects "Delete History" (permanent removal). |

---

## 5. Summary & Heatmap Discovery
*Measures engagement with long-term progress tracking.*

| Event Name | Parameters | Trigger |
| :--- | :--- | :--- |
| `view_summary_tab` | `month_year` | User switches to the Monthly Summary tab. |
| `heatmap_drill_down` | `task_type` | User taps a task in Summary to view its heatmap. |
| `heatmap_day_tap` | `has_activity` (True/False) | User taps a specific day on the calendar heatmap. |

---

## 6. Notifications & System Health
*Ensures technical features and localization are performing correctly.*

| Event Name | Parameters | Trigger |
| :--- | :--- | :--- |
| `notification_enabled` | `time_of_day`, `frequency` | User switches the "Reminder" toggle to ON. |
| `notification_denied` | `none` | User selects "Don't Allow" on the iOS system prompt. |
| `app_locale_set` | `language` (EN, PL) | Logged at app launch to track demographic distribution. |

---

## Implementation Notes
- **Privacy Manifest:** Ensure `FirebaseAnalytics` is declared in `PrivacyInfo.xcprivacy` under "Product Interaction" and "Device Identifiers."
- **User Properties:** Recommended to set `total_tasks_count` as a User Property to segment "Power Users" from "Casual Users."

## Firebase Console Setup Notes
- Enable **Google Analytics** for the Firebase project and keep the iOS app linked to the same `GoogleService-Info.plist` already bundled in the app target.
- In **Analytics -> Events**, verify the custom events above begin appearing after a local run. Use DebugView during development for immediate validation.
- In **Analytics -> Custom definitions**, register these event-scoped custom dimensions/metrics so the parameters are queryable in reports:
  - Dimensions: `task_type`, `frequency`, `step_reached`, `error_type`, `new_status`, `method`, `direction`, `view`, `task_name`, `month_year`, `has_activity`, `time_of_day`, `language`
  - Metrics: `amount`, `duration_minutes`, `days_snoozed`
- Register the user property `total_tasks_count` if you want to build audiences and comparisons around task volume.
- The app logs analytics through the DI-backed `AnalyticsService`, so future analytics additions should go through that abstraction instead of calling Firebase APIs directly from views.
