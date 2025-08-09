# CLAUDE.md

This file provides guidance to Claude Code when working with the BioLogger Flutter application.

## Project Overview

BioLogger is a Flutter application for tracking personal metrics and life quality data. Users define custom parameters (Sleep Hours, Mood, etc.), log daily progress, and export data to CSV format.

## Essential Commands

```bash
# Flutter development
flutter pub get              # Install dependencies - run this first!
flutter run                  # Run app on connected device/simulator  
flutter test                 # Run unit and widget tests
flutter analyze             # Static code analysis with linting
flutter clean               # Clean build artifacts if issues occur

# Testing specific functionality
flutter run --debug         # Run in debug mode for hot reload
flutter test test/          # Run all tests
flutter build apk --debug   # Build debug APK for testing

# Git workflow  
git status                  # Check current changes
git add .                   # Stage all changes
git commit -m "message"     # Commit with descriptive message
git push origin main        # Push to remote repository
```

## Current Priority Tasks

**IMPORTANT**: We are implementing these specific features:

1. **Replace "Next" button with "Save" on last parameter**
   - Find the data entry navigation logic in `lib/presentation/screens/`
   - Detect when user is on the final parameter
   - Change button text and behavior accordingly

2. **Add comment fields for each parameter**
   - Update Parameter model to include comment field
   - Modify database schema (add comment column to daily_records table)
   - Add text input UI below each parameter input field
   - Update save/load logic to handle comments

3. **Redesign application UI**
   - Implement Material Design 3 principles
   - Use modern color scheme and typography
   - Add smooth animations between screens
   - Improve spacing, shadows, and visual hierarchy

## Code Standards & Architecture

```dart
// Use GetX for state management
class MyController extends GetxController {
  // Reactive variables
  var isLoading = false.obs;
  
  // Methods should be async when needed
  Future<void> saveData() async { }
}

// Follow Clean Architecture layers:
// Presentation -> Domain -> Data
// UI calls Controller -> Controller calls UseCase -> UseCase calls Repository
```

**Architecture Pattern**: Clean Architecture with three layers:
- **Presentation**: `lib/presentation/screens/` + GetX controllers in `lib/domain/controllers/`
- **Domain**: Business logic in `lib/domain/use_cases/`
- **Data**: Repositories in `lib/data/repositories/` and DAOs in `lib/data/local_database/`

## Key Technical Details

- **Database**: SQLite with `sqflite` package
- **State Management**: GetX (already configured in `main.dart`)
- **Data Types Supported**: Number, Text, Rating, Yes/No, Time, Date
- **Main Models**: Parameter (parameter definitions), DailyRecord (daily entries)

## Workflow Instructions

**YOU MUST follow this sequence when making changes:**

1. **Read and understand code first** - explore relevant files before making changes
2. **Make incremental changes** - implement one feature at a time
3. **Test after each change** - run `flutter run` to verify functionality
4. **Commit frequently** - use descriptive commit messages
5. **Use TDD approach** - write tests first when possible

## Database Schema Notes

```sql
-- Parameters table stores parameter definitions
CREATE TABLE parameters (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  data_type TEXT NOT NULL, -- Number, Text, Rating, YesNo, Time, Date
  unit TEXT,
  created_at TEXT
);

-- Daily records table stores user entries
CREATE TABLE daily_records (
  id INTEGER PRIMARY KEY,
  parameter_id INTEGER,
  value TEXT NOT NULL,
  comment TEXT,  -- NEW: Add this field for comments
  date TEXT NOT NULL,
  FOREIGN KEY (parameter_id) REFERENCES parameters (id)
);
```

## UI/UX Guidelines

- **Material Design 3**: Use modern elevation, colors, and typography
- **Responsive design**: Ensure UI works on different screen sizes
- **Accessibility**: Proper contrast ratios and semantic widgets
- **Animations**: Use smooth transitions between screens (Hero animations, fade transitions)
- **User feedback**: Show loading states, success/error messages via SnackBars

## File Locations to Focus On

- **Data Entry Screen**: `lib/presentation/screens/data_entry/` or similar
- **Parameter Models**: `lib/models/parameter.dart`
- **Database Helper**: `lib/data/database_helper.dart`
- **Controllers**: `lib/domain/controllers/`
- **Theme Configuration**: `lib/presentation/theme/` (create if doesn't exist)

## Important Warnings

- **ALWAYS test changes** with `flutter run` before proceeding to next task
- **Database migrations**: When changing schema, implement proper migration logic
- **GetX reactive variables**: Use `.obs` for reactive state and `.update()` to trigger UI updates
- **Async operations**: Always handle Future/async operations properly with try-catch blocks

## Dependencies Already Available

```yaml
get: ^4.6.5              # State management - USE THIS for controllers
sqflite: ^2.0.0          # Database - for schema changes
path_provider: ^2.0.14   # File paths
share_plus: ^7.2.1       # Sharing functionality  
intl: ^0.18.0           # Date/time formatting
flutter_lints: ^5.0.0   # Code quality - follow linting suggestions
```

## Development Tips

- **Hot reload**: Save files to see changes instantly during `flutter run`
- **Debug console**: Check debug output for errors and print statements
- **Use descriptive variable names**: `isLastParameter` not `isLast`
- **Error handling**: Wrap database operations in try-catch blocks
- **Performance**: Avoid rebuilding entire UI - use GetX selective updates

## Testing Strategy

```bash
# Test specific functionality
flutter test test/models/           # Test data models
flutter test test/controllers/      # Test business logic
flutter test test/database/         # Test database operations

# Integration testing
flutter run --debug                 # Manual testing with hot reload
```
## Project Structure

lib/
├── main.dart                    # App entry point with dependency injection
├── models/                      # Data models (Parameter, DailyRecord)
├── data/                        # Data layer
│   ├── database_helper.dart     # SQLite database setup and migrations
│   ├── local_database/          # DAOs for database operations
│   └── repositories/            # Repository implementations
├── domain/                      # Business logic layer
│   ├── controllers/             # GetX controllers
│   └── use_cases/              # Business use cases
├── presentation/               # UI layer
│   └── screens/               # Flutter screens/pages
└── utils/                     # Utility classes (CSV export, etc.)