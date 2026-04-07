# TaskLedger — Manual QA Test Plan

**App:** TaskLedger  
**Platform:** iOS  
**Last updated:** April 2026

---

## App Overview

TaskLedger is a personal habit and expense tracker. Users create recurring or one-time tasks of four types (Counter, Cost, Income, Time), mark them complete each day, and review monthly summaries with a calendar heatmap.

---

## Feature Summary

| # | Feature | Description |
|---|---------|-------------|
| 1 | **Task Creation** | Create tasks with a name, type, and frequency |
| 2 | **Task Types** | Counter · Cost · Income · Time — each with distinct inputs |
| 3 | **Frequency Settings** | Daily (every day) · Weekly (specific weekdays) · Monthly (specific day of month) · One-Time (specific date) |
| 4 | **Daily View** | Browse tasks scheduled for a given day; mark tasks done/undone |
| 5 | **Day Navigation** | Swipe forward/backward through days using arrow buttons |
| 6 | **Task Check/Uncheck** | Tap a task to toggle its completion for the viewed day |
| 7 | **Swipe Actions** | Swipe a task row to reveal Archive or Snooze buttons |
| 8 | **Task Snooze** | Delay a task by 1–30 days from today |
| 9 | **Task Delete** | Permanently delete a task and its history, or just archive the schedule |
| 10 | **Calendar Picker** | Tap calendar icon to jump to any date |
| 11 | **Tasks List** | View all existing tasks |
| 12 | **Monthly Summary** | Second tab shows all tasks with activity this month and summary totals |
| 13 | **Summary Details** | Tap a task in Summary to see per-day calendar heatmap + event list |
| 14 | **Month Navigation** | Arrow buttons in Summary to browse previous/next months |
| 15 | **Summary Details Day Drill-Down** | Tap a highlighted calendar day to open that day's DayView from SummaryDetails |
| 16 | **Pull-to-Refresh** | Pull down list to reload tasks |
| 17 | **CloudKit Sync** | Data syncs across devices via iCloud |
| 18 | **Haptic Feedback** | Medium haptic triggered when checking/unchecking a task |
| 19 | **Localization** | English and Polish language support |
| 20 | **Form Validation** | Save button disabled until task name is filled and required fields are valid |

---

## Test Environment

- **Devices:** iPhone (any modern model running iOS 17+)
- **Accounts:** iCloud account required for CloudKit sync tests
- **Language:** Test in both English and Polish where noted

---

## Test Cases

---

### MODULE 1 — Task Creation

#### TC-01: Create a Counter task (daily repeat)
**Preconditions:** App installed and open on Day View  
**Steps:**
1. Tap the **+** floating action button
2. Verify the Add Task sheet appears
3. Select task type **Counter** (first button in type switcher)
4. Enter a task name, e.g. "Morning Run"
5. Select frequency **Daily**
6. Tap **Save**

**Expected:**
- Sheet dismisses
- "Morning Run" appears in the Day View list
- Task shows "Every day" label below the name

---

#### TC-02: Create a Counter task (weekly repeat — specific days)
**Steps:**
1. Open Add Task sheet
2. Select type **Counter**, enter name "Team Meeting"
3. Select frequency **Weekly**
4. Select **Mon**, **Wed**, **Fri** from the day selector
5. Tap **Save**

**Expected:**
- Task appears in Day View only on Mondays, Wednesdays and Fridays
- On other days the task is absent

---

#### TC-03: Create a Cost task
**Steps:**
1. Open Add Task sheet
2. Select type **Cost** (second button)
3. Enter name "Coffee", enter amount **4.50**
4. Select frequency **Daily**
5. Tap **Save**

**Expected:**
- "Coffee" appears in Day View with a Cost icon
- Monthly Summary will show the cumulative cost

---

#### TC-04: Create an Income task
**Steps:**
1. Open Add Task sheet
2. Select type **Income**
3. Enter name "Freelance Invoice", enter amount **500**
4. Select frequency **Monthly**, pick day **1**
5. Tap **Save**

**Expected:**
- Task appears only on the 1st of each month

---

#### TC-05: Create a Time task
**Steps:**
1. Open Add Task sheet
2. Select type **Time**
3. Enter name "Meditation", set duration **0 h 15 m 0 s**
4. Select frequency **Daily**
5. Tap **Save**

**Expected:**
- Task appears daily; tapping it records 15 minutes in the summary

---

#### TC-06: Create a One-Time task
**Steps:**
1. Open Add Task sheet
2. Enter name "Doctor Appointment"
3. Select frequency **One-Time**
4. Pick a date 3 days from today using the calendar
5. Tap **Save**

**Expected:**
- Task does not appear today
- Task appears on the selected date only

---

#### TC-07: Validation — empty task name
**Steps:**
1. Open Add Task sheet
2. Leave name field empty
3. Observe Save button state

**Expected:**
- Save button is disabled / greyed out
- Cannot submit form

---

#### TC-08: Validation — Cost/Income with zero amount
**Steps:**
1. Open Add Task sheet
2. Select type **Cost**, enter a name, leave amount at 0
3. Observe Save button state

**Expected:**
- Save button is disabled until amount > 0

---

#### TC-09: Validation — Weekly with no days selected
**Steps:**
1. Open Add Task sheet
2. Enter a name, select frequency **Weekly**, select no days
3. Observe Save button

**Expected:**
- Save button is disabled until at least one weekday is selected

---

### MODULE 2 — Day View

#### TC-10: Day view shows correct tasks for today
**Steps:**
1. Open app to Day View
2. Verify today's date is shown in the navigation bar

**Expected:**
- Only tasks scheduled for today are shown
- Tasks scheduled for other days (e.g. weekly but not today) are absent

---

#### TC-11: Navigate to next/previous days
**Steps:**
1. Tap **>** (next day) arrow
2. Verify date increments by 1 day
3. Tap **<** (previous day) twice
4. Verify date is yesterday

**Expected:**
- Task list updates to reflect the selected day on each navigation

---

#### TC-12: Mark a task as done
**Steps:**
1. Find an unchecked task in Day View
2. Tap it

**Expected:**
- Task icon changes to filled/checked state
- Haptic feedback fires
- Task remains in the list (does not disappear)

---

#### TC-13: Unmark a task (toggle off)
**Steps:**
1. Find a checked task
2. Tap it again

**Expected:**
- Task reverts to unchecked state
- Haptic feedback fires

---

#### TC-14: Swipe to delete (archive schedule)
**Steps:**
1. Swipe a task row to the left to reveal actions
2. Tap the **Delete (archive)** button
3. Confirm the dialog with "Archive Schedule"

**Expected:**
- Task disappears from Day View going forward
- Historical completion data is preserved (visible in Summary)

---

#### TC-15: Swipe to delete (delete all history)
**Steps:**
1. Swipe a task row left → Delete action → Confirm "Delete History"

**Expected:**
- Task disappears from Day View
- Task no longer appears in Monthly Summary

---

#### TC-16: Swipe to snooze
**Steps:**
1. Swipe a task left → tap **Snooze**
2. Pick **7 days** in the picker
3. Tap **Snooze** confirm button

**Expected:**
- Task disappears from today's view
- Task reappears 7 days from today

---

#### TC-17: Calendar date picker
**Steps:**
1. Tap the calendar icon in the toolbar
2. Select a date 2 weeks ago

**Expected:**
- Calendar sheet dismisses
- Day View updates to show that past date
- Date string in navigation bar updates correctly

---

#### TC-18: Empty state
**Steps:**
1. Navigate to a day that has no tasks scheduled

**Expected:**
- "Nothing to see here" empty-state message is displayed
- No task list is shown

---

#### TC-19: Pull-to-refresh
**Steps:**
1. Pull down on the task list

**Expected:**
- List refreshes without crash
- Tasks for the selected date are reloaded

---

### MODULE 3 — Monthly Summary

#### TC-20: Summary tab shows current month
**Steps:**
1. Tap the **Summary** tab

**Expected:**
- Navigation bar shows current month and year (e.g. "April 2026")
- Each task with activity this month appears in the list with a summary value

---

#### TC-21: Summary shows correct totals
**Steps:**
1. In the current month, mark a Cost task 3 times with amount 10
2. Open Summary tab

**Expected:**
- The Cost task row shows a total of 30 (in local currency)
- A Counter task shows count of completions (e.g. "3×")

---

#### TC-22: Navigate to previous/next month
**Steps:**
1. Tap **<** to go to previous month
2. Verify month changes
3. Tap **>** twice to go to next month

**Expected:**
- Task list updates to show that month's activity
- Tasks with no activity that month are hidden

---

#### TC-23: Pull-to-refresh in Summary
**Steps:**
1. Pull down on the Summary task list

**Expected:**
- List refreshes without crash

---

### MODULE 4 — Summary Details (Task Heatmap)

#### TC-24: Open Summary Details
**Steps:**
1. In Summary, tap any task row

**Expected:**
- Summary Details screen opens
- Calendar heatmap shows coloured circles on days with activity
- Days without activity show plain numbers

---

#### TC-25: Heatmap accuracy
**Steps:**
1. Note which days a task was marked in the current month
2. Open its Summary Details

**Expected:**
- Coloured dots appear exactly on the days the task was marked
- Empty days have no dot

---

#### TC-26: Event list in Summary Details
**Steps:**
1. Open Summary Details for a task with several completions

**Expected:**
- Below the calendar, a list shows each day with a completion count
- Sorted chronologically
- Count matches actual completions

---

#### TC-27: Summary total footer
**Steps:**
1. Open Summary Details for a Cost task

**Expected:**
- Footer bar shows "Total" label and the summed currency amount for the visible month

---

#### TC-28: Drill into a specific day from heatmap
**Steps:**
1. In Summary Details, tap a highlighted (coloured) calendar day

**Expected:**
- A DayView sheet opens for that date
- The task appears in the list for that day

---

#### TC-29: Change month in Summary Details
**Steps:**
1. In Summary Details, swipe the calendar left to go to next month (or use month navigation if present)

**Expected:**
- Heatmap updates to show that month's data
- Event list updates accordingly
- Total footer updates

---

#### TC-30: Dismiss DayView sheet and heatmap refreshes
**Steps:**
1. From Summary Details, tap a day → mark the task → tap Done
2. Dismiss the DayView sheet

**Expected:**
- Summary Details heatmap refreshes to show the newly marked day

---

### MODULE 5 — Data Persistence & Sync

#### TC-31: Data persists after app restart
**Steps:**
1. Create a task and mark it done
2. Force-quit the app
3. Reopen the app

**Expected:**
- Task still exists
- Completion mark is still shown

---

#### TC-32: CloudKit sync (two devices)
**Preconditions:** Two devices signed into same iCloud account  
**Steps:**
1. On Device A: create a new task "Sync Test"
2. Wait ~30 seconds
3. Open app on Device B

**Expected:**
- "Sync Test" task appears on Device B

---

### MODULE 6 — Localisation

#### TC-33: Polish language
**Steps:**
1. Set device language to Polish
2. Open app

**Expected:**
- All visible strings are in Polish (tab labels, task type names, buttons, alerts)
- No untranslated "raw key" strings visible (e.g. no `"task_type_counter"` shown literally)

---

### MODULE 7 — Error Handling

#### TC-34: Error alert on save failure (simulated)
**Steps:**
1. Enable Airplane mode
2. Attempt to create and save a task

**Expected:**
- If a save error occurs, an error alert is shown to the user
- App does not crash or silently fail

---

#### TC-35: Error alert on mark failure (simulated)
**Steps:**
1. Put device in a state where storage is full (hard to test manually — verify via code review that the alert path exists)

**Expected (code-level):**
- `DayViewViewModel.markTask` catch block sets `errorMessage`
- `DayView` shows an alert with a user-readable message

---

### MODULE 8 — Edge Cases

#### TC-36: Task scheduled for 31st — short month
**Steps:**
1. Create a Monthly task for the **31st**
2. Navigate to a month with 30 days (e.g. April)

**Expected:**
- Task does not appear in April (no 31st)
- Task appears correctly in March and May

---

#### TC-37: Weekly task with all 7 days selected
**Steps:**
1. Create a Weekly task with all 7 days selected
2. Check Day View on different days of the week

**Expected:**
- Task appears every day of the week
- Label shows "Every day"

---

#### TC-38: Snoozed task reappears on correct date
**Steps:**
1. Snooze a task for 3 days
2. Navigate to today+2 → task should NOT appear
3. Navigate to today+3 → task SHOULD appear

**Expected:**
- Task hidden until exactly the snooze date

---

#### TC-39: Long task name display
**Steps:**
1. Create a task with a 60-character name
2. View it in the Day View list and Summary

**Expected:**
- Name is truncated or wraps cleanly — no layout overflow or clipping of other elements

---

#### TC-40: Many tasks in a single day
**Steps:**
1. Create 20+ tasks all repeating daily
2. Open Day View for today

**Expected:**
- All tasks appear in a scrollable list
- No performance lag or crash

---

## Regression Checklist

After any code change, verify these core flows still work:

- [ ] Create a task of each type (Counter, Cost, Income, Time)
- [ ] Mark a task done and verify it persists
- [ ] Unmark a task
- [ ] Snooze a task and verify it disappears then reappears
- [ ] Archive a task (schedule deleted, history kept)
- [ ] Summary tab shows the correct month totals
- [ ] Summary Details heatmap renders without blank screen
- [ ] No crash on fresh install with empty state

---

## Bug Report Template

When filing a bug, include:

```
Title: <Short description>
Severity: Critical / Major / Minor / Cosmetic
Steps to Reproduce:
  1.
  2.
Expected Result:
Actual Result:
Device: iPhone XX, iOS XX.X
Language: EN / PL
Screenshot/Recording: [attach]
```
