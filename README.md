# ✅ Task Manager (Optional AI Assistant)

A simple, category-based to-do list app with reminders, due dates, and an optional AI-powered assistant to generate tasks from plain text prompts.

---

## Features

- Add, categorize, and schedule tasks
- Smart reminder intervals: Every Minute, Hourly, Daily, Weekly
- Dark Mode support
- Toggleable in-app vibration and notification settings
- Speech-to-Text input for fast task creation
- Optional: AI-powered task generation (Gemini)
- Clipboard access toggle (optional)
- Auto-delete completed tasks (optional)
- Delete task on dismiss (swipe gesture)
- Bulk trash management

---

## Setup

```bash
git clone https://github.com/CovenantJunior/task_manager.git
cd task_manager
flutter pub get
```
To enable AI:

```bash
Gemini.init(apiKey: 'GEMINI-API-KEY');
```
## Example Prompt

"Plan 3 work tasks and 2 wellness tasks for this weekend"

## Notes

- Uses `gemini-1.5-flash` (optional)  
- Tasks are parsed from numbered output  
- If date detected (e.g., "tomorrow"), opens manual task dialog

## Snapshots
| Task Input | Task List | Task Details | Preferences |
|------------|-----------|--------------|-------------|
| ![input](https://github.com/user-attachments/assets/f66e1d96-c9c5-489a-9a9d-53b183ce0989) | ![list](https://github.com/user-attachments/assets/2b9e58c8-65a8-4116-b519-b38e44be99f5) | ![details](https://github.com/user-attachments/assets/fba5829a-7df4-40fd-9eb5-439fa1a16403) | ![prefs](https://github.com/user-attachments/assets/7c25e372-8e06-487d-9ad4-14a290e990bf) |