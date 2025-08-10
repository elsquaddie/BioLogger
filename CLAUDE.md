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
flutter test test/models/   # Test specific models
flutter test test/controllers/ # Test business logic
flutter test test/presentation/ # Test UI components
flutter build apk --debug   # Build debug APK for testing

# Git workflow  
git status                  # Check current changes
git add .                   # Stage all changes
git commit -m "message"     # Commit with descriptive message
git push origin main        # Push to remote repository
```

## ПРИОРИТЕТ: Календарь + Пресет параметров + Экран данных

**ПРЕСЕТ ПАРАМЕТРОВ (создается автоматически при первом запуске):**

Дефолтные параметры с иконками из values.html:
1. Сон (Number, часы) → Icons.bedtime  
2. БАДы (Text) → Icons.medication  
3. Оценка качества работы (Rating 1-10) → Icons.work
4. Тренировка (Number, минуты) → Icons.fitness_center
5. Количество шагов (Number) → Icons.directions_walk
6. Оценка социальности (Rating 1-10) → Icons.people
7. Оценка настроения (Rating 1-10) → Icons.sentiment_satisfied
8. Оценка своей привлекательности (Rating 1-10) → Icons.favorite
9. Оценка самореализации (Rating 1-10) → Icons.star
10. Оценка качества питания (Rating 1-10) → Icons.restaurant
11. Оценка текущих финансов (Rating 1-10) → Icons.attach_money
12. Оценка социальной полезности (Rating 1-10) → Icons.public
13. Оценка прошедшего дня (Rating 1-10) → Icons.thumb_up
14. Почему такая оценка (Text) → Icons.edit_note
15. Воспоминания обо дне (Text) → Icons.book

**СТРУКТУРА БД:**
- Поле `is_preset: boolean` для пометки дефолтных
- Поле `is_enabled: boolean` для включения/отключения
- Поле `sort_order: int` для пользовательского порядка
- Дефолтные параметры нельзя удалить, только отключить

**ПОЛЬЗОВАТЕЛЬСКИЕ ПАРАМЕТРЫ:**
- Иконка по умолчанию: Icons.analytics
- Добавляются после дефолтных в списке
- Можно удалять и редактировать

**КАЛЕНДАРЬ + ЭКРАН ДАННЫХ:** 

**КАЛЕНДАРЬ - исправления:**
1. Заполненные дни = цифра ВНУТРИ зеленого кружка (не точка под цифрой)
2. Выбранная незаполненная дата = серый кружок вокруг цифры  
3. Выбранная + заполненная = зеленый кружок + двойная обводка/увеличенный размер
4. Кнопка: "Записать данные" / "Посмотреть данные" 
5. Заголовок над счетчиками: "Серии заполнений:"

**ЭКРАН ДАННЫХ - полная переработка на основе values.html:**
- Единый экран просмотра/редактирования  
- Карточки как в values.html: иконка + название + значение
- values.html - лишь референс. Нужно брать из него картинки (в будущем это будут предзаданные в бд параметры)
- Клик по карточке → увеличение + поля ввода + автофокус
- Вертикальный скролл между карточками при заполнении
- Комментарии под основным полем (обрезка если длинные)
- Кнопка "Далее" → "Сохранить" на последнем параметре

**УДАЛИТЬ типы полей:** Date и Time (оставить Number, Text, Rating, Yes/No)

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

**Key Architecture Components**:
- **Models**: `Parameter` and `DailyRecord` classes in `lib/models/`
- **Database**: SQLite via `DatabaseHelper` with version-controlled migrations
- **Dependency Injection**: Centralized in `main.dart` using GetX `AppBindings`
- **State Management**: Reactive variables with GetX `.obs` and `.update()`

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

**Current Schema (v4)**:
```sql
-- Parameters table stores parameter definitions  
CREATE TABLE parameters (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  data_type TEXT NOT NULL, -- Number, Text, Rating, YesNo (Date/Time removed)
  unit TEXT,
  scale_options TEXT -- JSON array for Rating scales
);

-- Daily records table stores user entries
CREATE TABLE daily_records (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL, -- ISO 8601 date format
  dataValues TEXT NOT NULL, -- JSON map of parameter_id -> value
  comments TEXT -- JSON map of parameter_id -> comment
);
```

**Important Notes**:
- Database migrations handled in `DatabaseHelper._onUpgrade()` 
- DailyRecord stores all parameter values for a date in single JSON fields
- Parameter types limited to: Number, Text, Rating, YesNo (Date/Time removed per requirements)

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