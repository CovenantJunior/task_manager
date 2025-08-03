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

