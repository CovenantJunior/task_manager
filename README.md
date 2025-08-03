# ✅ Task Manager (Optional AI Assistant)

A simple, category-based to-do list app with reminders, due dates, and an optional AI-powered assistant to generate tasks from plain text prompts.

---

## 🚀 Features

- Add, categorize, and schedule tasks
- Set reminders/notifications (minute, hourly, daily, weekly)
- Speech-to-text input support
- ✅ Optional: Use AI (Gemini) to generate task lists from prompts

---

## 🛠 Setup

```bash
git clone https://github.com/CovenantJunior/task_manager.git
cd task_manager
flutter pub get
```
To enable AI:

```bash
Gemini.init(apiKey: 'GEMINI-API-KEY');
```
## 💡 Example Prompt

"Plan 3 work tasks and 2 wellness tasks for this weekend"

## 📌 Notes

- Uses `gemini-1.5-flash` (optional)  
- Tasks are parsed from numbered output  
- If date detected (e.g., "tomorrow"), opens manual task dialog  