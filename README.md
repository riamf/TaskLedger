# TaskLedger: Product Design Document

---

## 1. Product Overview and Context

### 1.1 Product Name and Description
Task Ledger is an iOS app that alows users to track their everyday activities like time spent on something, number of occurences of some event and
also a cost and income tracking. It provides monthly summaries and export csv functionality.

---

### 1.2 Problem Statement
Main priblem is tasks tracking, and summarizing over some period of time. There is no solution on the market that does just that.
Only possible way is excel/google sheet but it is cumbersome to use and maintain, also not available in the palm of your hand like mobile app is. 

---

### 1.3 Product Vision
In next year I want this app to be on AppStore and have more than 1k downloads.

---

## 2. Target Users and Personas

### 2.1 Primary User Persona
- Sarah the worker
- 20-60
- normal everyday worker aand house wife
- Needs to track income and expenses daily; wants monthly summaries to know where money goes
- Having knowledge about tasks done 
- iPhone with iOS
- There is no app that have all these features.

---

### 2.2 Secondary User Personas
- Bob the student
- 20-40
- normal student
- Needs to track time spend on some tasks, gaming, study sessions and event and how many times they occur
- Having knowledge about where time goes
- iPhone with iOS
- There is no app that have all these features.

---

### 2.3 User Needs and Jobs to Be Done
**Fill this in:** For each persona, describe the core "jobs" they need to accomplish with TaskLedger.

| Persona | Primary Job | Secondary Jobs | Success Criteria |
|---------|-------------|-----------------|------------------|
| [Persona 1] | Log in income and costs | Track how many times her kids where eating out this month | By using counter in app she will know it |
| [Persona 2] | Track time spend on gaming sessions | Track missed lessons or how many times he was late for lesson | Measuting time event in app and measuring timer occurences |

---

## 3. Feature Set and Functional Requirements

### 3.1 Core Features (Must Have for MVP)
**Fill this in:** List the essential features required for launch. For each feature, describe what it does and why it's critical.

**Feature 1: Defining Tasks**
- **Description**: User should be able to define task, this includes: naming task, selecting task type, adding notes(optional), adding amount(cost, income), adding time spent(time task), ability to define if task repeats, if not it is one time only task with fixed date
- **User Benefit**: Declared once task will be visible on day view
- **Success Criteria**: Added task is visible in task list and on day view if date filter match
- **UI Considerations**: Adding from home screen by using floating plus button

**Feature 2: Disaply Tasks for today**
- **Description**: Main app View should show all tasks defined for today, it should allow. marking task as done and visually show done tasks, maybe move them down to the list. This view should also allow to change current date forward or backward, and tasks list should adjust acordingly. This view should also allow pausing task and it should be moved to last section PAUSED where it could be broth back or would just be visible.
- **User Benefit**: User will be able to quickly mark tasks as done.
- **Success Criteria**: List displays all tasks with split done/not done.
- **UI Considerations**: Date switcher on top with navigaiton controls to switch to calendar summary and to show tasks lists, both views should be shown modally, there also should be a plus icon to show modally view for defining new task.


**Feature 3: Show Tasks list**
- **Description**: Tasks list should show all available tasks. You should be able to delete tasks with all its events from here(Mark as deleted but not delete events to be able to show them historically). You should be able to edit tasks from here also pause them.
- **User Benefit**: Quick and easy way to edit/delete/pause tasks.
- **Success Criteria**: Tasks list displays with some details on the list with ability to go to task edition.
- **UI Considerations**: Simplae CRUD list to disaply.


**Feature 4: Calendar View**
- **Description**: Calendar view should as name siggest show calendar with summary list below with all task events availbe on the presented month, this is also the place to export to csv file. Cost summary should add all costs group by task, income should work same as cost, time tasks should summarize all time spend on task counter should summarize ocurrences of tasks.
- **User Benefit**: Easy way of looking at month summary and one click export to csv.
- **Success Criteria**: Calendar clear view with marked current date and list of summarized task types , counters, income, costs, timers.
- **UI Considerations**: Clear design that will show list and nice calendar on top.


**Feature 5: Edit task**
- **Description**: This should work same as define task and should but also store old version.
- **User Benefit**: User will be able to quickly edit task name or reoccurences.
- **Success Criteria**: Task adding view is displayed with current data information.
- **UI Considerations**: Same as adding new tasks

---

### 3.2 Secondary Features (Should Have for v1.1)
- cost and income should have categories selector also screen to define these categories


---

### 3.3 Future Features (Could Have for v2+)
**Fill this in:** List features planned for later versions.

[Follow same structure as 3.1 for each "Could Have" feature]

---

### 3.4 Out of Scope Features (Won't Have)
**Fill this in:** Explicitly list features that are NOT planned for TaskLedger.

- [Feature name and why it's out of scope]
- [Feature name and why it's out of scope]

---

## 4. Data Model and Information Architecture

### 4.1 Core Entities
**Fill this in:** Define the main data entities your app will manage.

**Entity: [Name]**
- **Purpose**: [What this entity represents]
- **Key Properties**: [e.g., id, name, createdAt, updatedAt, ...]
- **Relationships**: [How it relates to other entities]
- **Business Rules**: [Any constraints or validation rules]

**Entity: [Name]**
[Repeat structure]

---

### 4.2 Data Relationships Diagram
**Fill this in:** Describe the relationships between entities.

*Example: "A Task has many Entries. Each Entry has a timestamp, amount (for costs/income), duration (for time), or count (for counters). A Task belongs to a Category."*

**Your data relationships:**
[Describe how entities relate]

---

### 4.3 Persistence Strategy
**Fill this in:** How will data be stored?

- **Primary Storage**: [e.g., Core Data, Realm, SQLite]
- **Backup Strategy**: [e.g., iCloud backup, manual export, automatic daily backup]
- **Offline Support**: [e.g., Full offline functionality, limited offline features]
- **Sync Strategy** (if applicable): [e.g., Manual sync, automatic sync, conflict resolution]

**Your persistence strategy:**
[Your response]

---

## 5. User Interface and Interaction Design

### 5.1 Main Views
**Fill this in:** For each main screen/view in your app, describe its purpose and key elements.

**View 1: [Name]**
- **Purpose**: [What is the view for?]
- **Key Elements**: [What components/sections does it contain?]
- **User Interactions**: [What can users do here?]
- **Navigation**: [How do users get here and where do they go next?]

**View 2: [Name]**
[Repeat structure]

---

### 5.2 Navigation Structure
**Fill this in:** How do users move between views?

- **Primary Navigation**: [e.g., Tab bar with 4 tabs: Home, Stats, Settings, Profile]
- **Secondary Navigation**: [e.g., Modal for task creation, detail screens for viewing/editing]
- **Edge Cases**: [e.g., What happens if user returns from background? How are deep links handled?]

**Your navigation structure:**
[Describe your app's navigation flow]

---

### 5.3 Design System
**Fill this in:** Define visual and interaction guidelines.

**Color Palette**
- **Primary Color**: [e.g., Teal #32B8C6]
- **Secondary Color**: [e.g., Orange #E68161]
- **Neutral Colors**: [e.g., White, Gray-100, Gray-800 for dark mode]
- **Status Colors**: [Success (green), Error (red), Warning (yellow), Info (blue)]

**Typography**
- **Headlines**: [e.g., SF Pro Display, 24pt, semibold]
- **Body Text**: [e.g., SF Pro Text, 16pt, regular]
- **Captions**: [e.g., SF Pro Text, 12pt, regular]

**Spacing and Layout**
- **Grid System**: [e.g., 8pt base unit]
- **Padding**: [e.g., 16pt standard padding, 8pt reduced]
- **Corner Radius**: [e.g., 8pt for small elements, 12pt for cards]

**Icons and Imagery**
- **Icon Set**: [e.g., SF Symbols, custom SVG]
- **Icon Style**: [e.g., Outlined, filled, multi-color]

**Motion and Feedback**
- **Animations**: [e.g., 300ms standard duration, spring easing]
- **Haptic Feedback**: [e.g., Light tap on button press, Success on completed action]

**Your design system:**
[Describe your visual language]

---

### 5.4 Accessibility Requirements
**Fill this in:** How will TaskLedger be accessible to all users?

- **Screen Reader Support**: [VoiceOver compatibility, semantic HTML labels]
- **Dynamic Type**: [Support for Large Text accessibility settings]
- **Color Contrast**: [WCAG AA or AAA compliance standards]
- **Keyboard Navigation**: [Tab order, keyboard shortcuts if applicable]

**Your accessibility approach:**
[Describe accessibility features]

---

## 6. User Flows and Workflows

### 6.1 Core User Flows
**Fill this in:** For each major user task, describe the step-by-step flow.

**Flow 1: [Task Name]**
1. User [action]
2. App [response]
3. User [action]
4. App [response]
...
End state: [What has been accomplished?]

**Flow 2: [Task Name]**
[Repeat structure]

---

### 6.2 Edge Cases and Error Handling
**Fill this in:** How does the app handle unexpected situations?

- **Empty State**: [What does user see when there's no data?]
- **Network Failure**: [How does app behave offline or with poor connection?]
- **Data Validation**: [What happens if user enters invalid data?]
- **Deletion Recovery**: [How can users undo actions?]

**Your error handling approach:**
[Describe how you handle edge cases]

---

## 7. Success Metrics and KPIs

### 7.1 Engagement Metrics
**Fill this in:** How will you measure if users are engaging with TaskLedger?

| Metric | Target | Rationale |
|--------|--------|-----------|
| Daily Active Users (DAU) | [e.g., 50 by month 1] | [Why this target?] |
| Day-7 Retention | [e.g., 70%] | [Why this target?] |
| Monthly Active Users (MAU) | [e.g., 60% of cumulative users] | [Why this target?] |
| Feature Adoption | [e.g., 80% create task in first session] | [Why this target?] |

**Your engagement metrics:**
[Fill in your targets and rationales]

---

### 7.2 Quality Metrics
**Fill this in:** How will you measure app quality?

| Metric | Target | Rationale |
|--------|--------|-----------|
| Crash Rate | [e.g., <0.1%] | [Why this target?] |
| Bug Report Rate | [e.g., <2% of users] | [Why this target?] |
| App Store Rating | [e.g., 4.5+ stars] | [Why this target?] |
| Performance (app launch) | [e.g., <2 seconds] | [Why this target?] |

**Your quality metrics:**
[Fill in your targets and rationales]

---

### 7.3 Business Metrics
**Fill this in:** How will you measure business success?

| Metric | Target | Rationale |
|--------|--------|-----------|
| App Store Downloads | [e.g., 500+ in month 1] | [Why this target?] |
| User Acquisition Cost | [e.g., $0 organic only] | [Why this target?] |
| Lifetime Value | [e.g., Free app, future monetization] | [Why this target?] |

**Your business metrics:**
[Fill in your targets and rationales]

---

## 8. Technical Architecture

### 8.1 Technology Stack
**Fill this in:** What technologies will you use?

| Component | Technology | Rationale |
|-----------|-----------|-----------|
| Language | [e.g., Swift] | [Why this choice?] |
| UI Framework | [e.g., SwiftUI] | [Why this choice?] |
| Persistence | [e.g., Core Data] | [Why this choice?] |
| Architecture | [e.g., MVVM + Coordinators] | [Why this choice?] |
| Testing | [e.g., XCTest] | [Why this choice?] |

**Your technology stack:**
[Fill in your choices and rationales]

---

### 8.2 Platform Requirements
**Fill this in:** What platforms and OS versions will you support?

- **Primary Platform**: [e.g., iOS 15.0+]
- **Device Support**: [e.g., iPhone SE through Pro Max]
- **iPad Support**: [Yes/No? When?]
- **macOS Support**: [Yes/No? When?]

**Your platform requirements:**
[Specify your target platforms]

---

### 8.3 Performance Requirements
**Fill this in:** What are your performance targets?

| Requirement | Target | Rationale |
|-------------|--------|-----------|
| App Launch Time | [e.g., <2 seconds] | [Why this target?] |
| View Rendering | [e.g., <1 second for main views] | [Why this target?] |
| Data Entry Response | [e.g., <300ms] | [Why this target?] |
| Memory Usage | [e.g., <100MB typical] | [Why this target?] |

**Your performance requirements:**
[Fill in your targets and rationales]

---

## 9. Timeline and Roadmap

### 9.1 MVP Timeline
**Fill this in:** When do you plan to launch the MVP?

| Phase | Duration | Deliverables | Target Date |
|-------|----------|--------------|------------|
| Planning & Design | [e.g., 2 weeks] | [What will be complete?] | [Date] |
| Implementation | [e.g., 6 weeks] | [What will be complete?] | [Date] |
| Testing & Polish | [e.g., 2 weeks] | [What will be complete?] | [Date] |
| Beta Testing | [e.g., 1 week] | [What will be complete?] | [Date] |
| Launch | [e.g., Week X] | [What will be complete?] | [Date] |

**Your timeline:**
[Fill in your phases and dates]

---

### 9.2 Post-Launch Roadmap
**Fill this in:** What features/improvements are planned after launch?

**v1.1 (Planned for [Month/Year])**
- [Feature 1 and why]
- [Feature 2 and why]

**v2.0 (Planned for [Month/Year])**
- [Major feature and why]
- [Major feature and why]

**Your roadmap:**
[Describe your post-launch plans]

---

## 10. Risks and Mitigation Strategies

### 10.1 Identified Risks
**Fill this in:** What could go wrong and how will you handle it?

| Risk | Likelihood | Impact | Mitigation Strategy |
|------|-----------|--------|-------------------|
| [Risk description] | [High/Medium/Low] | [What happens if this occurs?] | [How will you prevent or handle it?] |
| [Risk description] | [High/Medium/Low] | [What happens if this occurs?] | [How will you prevent or handle it?] |

**Your identified risks:**
[Fill in your risks and mitigation strategies]

---

## 11. Monetization Strategy (If Applicable)

### 11.1 Revenue Model
**Fill this in:** How will TaskLedger generate revenue?

- **Model**: [e.g., Free with optional premium, subscription, one-time purchase, ads]
- **Free vs. Paid Features**: [What's free and what's paid?]
- **Pricing** (if applicable): [e.g., $4.99/month or $39.99/year]
- **Justification**: [Why this model?]

**Your monetization strategy:**
[Describe your revenue approach]

---

## 12. Marketing and Launch Strategy

### 12.1 Target Marketing Channels
**Fill this in:** How will you attract users?

- **Channel 1**: [e.g., Product Hunt launch]
- **Channel 2**: [e.g., Social media (Twitter, Reddit)]
- **Channel 3**: [e.g., Tech blogs and communities]
- **Channel 4**: [e.g., Word of mouth / beta testers]

**Your marketing strategy:**
[Describe how you'll reach users]

---

### 12.2 Launch Communication
**Fill this in:** What will you communicate to users?

- **Core Message**: [e.g., "The simplest way to track your daily life"]
- **Key Differentiators**: [e.g., "Four specialized task types, beautiful month-end insights"]
- **Call to Action**: [e.g., "Download now for free"]

**Your launch messaging:**
[Describe your core messages]

---

## 13. Constraints and Assumptions

### 13.1 Development Constraints
**Fill this in:** What limitations will you work within?

- **Team**: [e.g., Solo developer, no designer]
- **Timeline**: [e.g., 13 weeks to launch]
- **Budget**: [e.g., $0–500]
- **Technical**: [e.g., Must work offline, no backend required]

**Your constraints:**
[Describe your limitations]

---

### 13.2 Key Assumptions
**Fill this in:** What are you assuming to be true?

- **User Assumption 1**: [e.g., Users will engage in daily logging]
- **Market Assumption 1**: [e.g., There's demand for specialized tracking]
- **Technical Assumption 1**: [e.g., Core Data is sufficient for v1]

**Your assumptions:**
[List your key assumptions]

---

## 14. Success Criteria and Go/No-Go Decision Points

### 14.1 MVP Launch Criteria
**Fill this in:** What must be true to launch the MVP?

- [Criterion 1: e.g., All "Must Have" features working without crashes]
- [Criterion 2: e.g., <0.5% crash rate in internal testing]
- [Criterion 3: e.g., Core workflows complete in <1 minute]
- [Criterion 4: e.g., Design polished and responsive]

**Your launch criteria:**
[Define what "done" means for MVP]

---

### 14.2 Post-Launch Success Criteria
**Fill this in:** What indicates you've succeeded in the market?

- [Criterion 1: e.g., 70%+ day-7 retention]
- [Criterion 2: e.g., 4.5+ App Store rating]
- [Criterion 3: e.g., 500+ downloads in month 1]
- [Criterion 4: e.g., Positive user feedback on core workflows]

**Your post-launch success criteria:**
[Define what market success looks like]

---

## 15. Document Version and Approval

### 15.1 Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 (Template) | [Date] | [Your Name] | Initial product design document template |
| [Your version] | [Date] | [Your Name] | [What you changed] |

---

### 15.2 Sign-off and Approval

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Product Owner | [Your Name] | [Date] | \_\_\_\_\_\_\_\_\_\_ |
| Designer (if applicable) | [Name] | [Date] | \_\_\_\_\_\_\_\_\_\_ |
| Developer Lead | [Your Name] | [Date] | \_\_\_\_\_\_\_\_\_\_ |

---

## Next Steps After Completing This Template

1. **Share for Feedback**: Review with stakeholders and gather input
2. **Create User Stories**: Convert features into detailed user stories with acceptance criteria
3. **Design Wireframes**: Create low-fidelity wireframes for each main view
4. **Design High-Fidelity Mockups**: Build polished UI mockups following your design system
5. **Define Core Data Schema**: Translate data model section into database schema
6. **Set Up Development Environment**: Create Xcode project with initial structure
7. **Plan First Sprint**: Break down features into tickets for development

---

**This template is now complete. Fill in each section thoroughly, and you'll have a comprehensive product design specification ready for development!**
