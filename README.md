# BirthdayReminder

A lightweight iOS app built with SwiftUI and SwiftData to remind you of birthdays for family, friends, and loved ones — with smart milestone-based notifications.

This project is developed iteratively with clear steps, frequent commits, and real-device validation.

---

## Features

- 📅 Manage a list of people with name, relation, birthday, and enabled status
- 🔔 Local notifications for upcoming birthdays:
  - 30 days before
  - 2 days before
- 🎁 Smart milestone reminders:
  - **Kids (<12)**: special gift reminders when turning **3, 5, or 10**
  - **Older adults (45+)**: important decade milestones (**50, 60, 70, 80, …**)
- 🧠 Offline logic (no backend, no external APIs)
- 🧪 Built-in debug section (DEBUG builds only):
  - Enabled people count
  - Next upcoming birthdays preview
  - Manual “Reschedule Notifications” button

---

## Tech Stack

- **SwiftUI** – UI framework
- **SwiftData** – Local persistence
- **UserNotifications** 
