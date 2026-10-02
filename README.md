# DailyFlow 🌊

**DailyFlow** is a sleek, minimalist daily routine & habit tracking app built with Flutter. It helps users maintain consistent daily habits with clean visual analytics, zero-cron daily auto-resets, and streak tracking.

---

## ✨ Features

- **Zero-Cron Automatic Reset**: Daily routines automatically reset to unchecked every midnight deterministically without requiring background cron jobs or external servers.
- **Consecutive Streak Counter**: Automatically tracks daily completion streaks. Missing a day resets the streak, while completing daily builds up your streak counter (`🔥 5 days streak`).
- **Dark Minimalist Aesthetic**:
  - Deep slate background (`#0F172A`)
  - Rich surface cards (`#1E293B`)
  - Emerald green accent (`#10B981`) for completed tasks
  - Electric indigo (`#6366F1`) for primary actions and tags
- **Header Progress Ring & Analytics**: Displays today's formatted date (e.g. *Friday, Oct 2*), "X of Y routines done today", active completion percentage, and longest active streak.
- **Interactive Task Cards**:
  - Animated glowing checkmark button.
  - Smooth text strike-through & opacity transition on completion.
  - Category tag & emoji icons.
  - Swipe-to-delete action (`Dismissible`) with SnackBar **Undo** support.
- **Category Filter Bar**: Quickly filter routines by categories (All, Fitness, Mind, Learning, Health, Work, Personal).
- **Search & Quick Actions**: Instant live title search and single-tap "Reset Progress" for testing.
- **Local Persistence**: Integrated with `shared_preferences` for offline data persistence.

---

## 🛠 Project Structure

```
lib/
├── main.dart                   # Main entry point & HomeScreen
├── models/
│   └── routine_task.dart       # RoutineTask data model & date/streak logic
├── providers/
│   └── task_provider.dart      # Reactive state management with Provider
├── services/
│   └── storage_service.dart    # SharedPreferences local storage service
├── theme/
│   └── app_theme.dart          # Dark slate theme tokens & typography
├── utils/
│   └── date_utils.dart         # Date formatting utilities
└── widgets/
    ├── add_task_sheet.dart     # Modal bottom sheet for creating routines
    ├── category_chip.dart      # Category filter row
    ├── empty_state_widget.dart  # Friendly empty state widget
    ├── progress_card.dart      # Header progress bar & date card
    └── task_card.dart          # Interactive task list card
```

---

## 🚀 Getting Started

1. Clone or open the repository.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

---

## 💡 Auto-Reset Logic Explained

The auto-reset logic uses deterministic date string comparisons:
- Each task stores `lastCompletedDate` as a string (`yyyy-MM-dd`).
- A task is completed if and only if `lastCompletedDate == todayString`.
- When midnight passes, `todayString` changes automatically, so `isCompletedToday` returns `false` without needing background jobs.
