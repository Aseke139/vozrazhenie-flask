# Flutter Task Manager (Android + SQLite)

Simple mobile task manager app built with Flutter and SQLite.

## Features

- Create, edit, delete **Blocks** (categories)
- Create, edit, delete **Tasks** inside blocks
- Mark tasks completed with checkbox
- Completed tasks are crossed out visually
- Open task details to create, edit, delete **Comments**
- SQLite persistence with foreign keys and cascading deletes

## Database Schema

### blocks
- `id` INTEGER PRIMARY KEY AUTOINCREMENT
- `name` TEXT NOT NULL
- `created_at` TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP

### tasks
- `id` INTEGER PRIMARY KEY AUTOINCREMENT
- `block_id` INTEGER NOT NULL (FK -> blocks.id ON DELETE CASCADE)
- `title` TEXT NOT NULL
- `is_completed` INTEGER NOT NULL DEFAULT 0
- `created_at` TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP

### comments
- `id` INTEGER PRIMARY KEY AUTOINCREMENT
- `task_id` INTEGER NOT NULL (FK -> tasks.id ON DELETE CASCADE)
- `text` TEXT NOT NULL
- `created_at` TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP

## Run

1. Install Flutter SDK
2. From this folder run:
   ```bash
   flutter pub get
   flutter run
   ```

