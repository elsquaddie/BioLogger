# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BioLogger is a Flutter application for tracking personal metrics and life quality data. Users define custom parameters (Sleep Hours, Mood, etc.), log daily progress, and export data to CSV format.

## Essential Commands

```bash
# Development workflow
flutter pub get              # Install dependencies - ALWAYS run first after changes
flutter run                  # Run on connected device/simulator
flutter run --debug         # Debug mode with hot reload (recommended)
flutter analyze             # Static analysis and linting - run before commits
flutter test                 # Run all unit/widget tests
flutter clean               # Clean build artifacts if build issues occur

# Testing specific areas
flutter test test/models/           # Test data models
flutter test test/controllers/      # Test business logic controllers
flutter test test/presentation/     # Test UI components and screens
flutter test test/data/            # Test database operations
flutter test test/domain/use_cases/ # Test business use cases

# Build commands
flutter build apk --debug     # Debug APK for testing
flutter build apk --release   # Production APK

# Hot reload during development
r                             # Hot reload (in flutter run console)
R                             # Hot restart (in flutter run console)
```

## ПРИОРИТЕТ: Исправление UI/UX багов (Август 2025)

**ЗАДАЧА 1: Постоянная нижняя навигация (BottomNavigationBar)**
- **Проблема:** Экран "Управление параметрами" (`ParameterListScreen`) открывается поверх `MainNavigationScreen`, скрывая нижнюю панель навигации (см. скриншот 1).
- **Решение:** Рефакторинг навигации. `ParameterListScreen` не должен открываться как новый `Route`. Вместо этого, он должен отображаться **внутри** `MetricsScreen` (вкладка "Данные"), заменяя его содержимое. Это сохранит `Scaffold` и `BottomNavigationBar` от `MainNavigationScreen`.
- **Затронутые файлы:**
  - `lib/presentation/screens/metrics_screen.dart`
  - `lib/presentation/screens/parameter_list_screen.dart`
  - `lib/presentation/screens/main_navigation_screen.dart` (для возможного создания нового контроллера)

**ЗАДАЧА 2: Проблемы с клавиатурой на экране ввода данных**
- **Проблема 1:** На экране ввода данных клавиатура перекрывает поля ввода и комментариев, так как контент не прокручивается (см. скриншот 3).
- **Решение 1:** Обернуть содержимое страницы ввода данных в `SingleChildScrollView`, чтобы обеспечить прокрутку.
- **Проблема 2:** Клавиатура автоматически появляется для параметров типа "Rating", где она не нужна (см. скриншот 2).
- **Решение 2:** Реализовать логику, которая будет убирать фокус (`unfocus`) с текстовых полей, когда текущий параметр не требует клавиатуры (например, 'Rating' или 'YesNo').
- **Затронутый файл:** `lib/presentation/screens/data_entry_screen.dart`

**ЗАДАЧА 3: UI-дефект на экране создания параметра**
- **Проблема:** Текст-подсказка "Выберите тип данных" слишком длинный и выходит за границы поля (см. скриншот 4).
- **Решение:** Сократить или полностью убрать `hintText` в `DropdownButtonFormField`, оставив только `labelText`.
- **Затронутый файл:** `lib/presentation/screens/parameter_create_screen.dart`

**ЗАДАЧА 4: УДАЛИТЬ типы полей:** 
- Date и Time (оставить Number, Text, Rating, Yes/No)

**УДАЛИТЬ типы полей:** Date и Time (оставить Number, Text, Rating, Yes/No)

## Architecture & Technical Stack

**Framework**: Flutter with Material Design 3  
**State Management**: GetX (reactive programming with `.obs` variables)  
**Database**: SQLite via `sqflite` package with versioned migrations  
**Architecture**: Clean Architecture with three distinct layers

### Architecture Layers

**1. Presentation Layer** (`lib/presentation/`)
- Screens: UI components and pages
- Widgets: Reusable UI components (calendar, forms)
- Theme: Material Design 3 configuration

**2. Domain Layer** (`lib/domain/`)
- Controllers: GetX controllers managing UI state and business logic
- Use Cases: Business logic operations (CRUD, calculations, export)
- Services: Application services (preset parameters initialization)

**3. Data Layer** (`lib/data/`)
- DatabaseHelper: SQLite connection, schema creation, migrations
- DAOs: Data Access Objects for database operations
- Repositories: Abstract interfaces and concrete implementations

### Key Technical Patterns

```dart
// GetX State Management
class MyController extends GetxController {
  var isLoading = false.obs;        // Reactive variables
  var dataList = <Model>[].obs;     // Observable collections
  
  Future<void> loadData() async {
    isLoading.value = true;         // Triggers UI update
    // ... business logic
    isLoading.value = false;
  }
}

// Clean Architecture Flow
// UI -> Controller -> UseCase -> Repository -> DAO -> Database
```

### Dependency Injection
- Centralized in `main.dart` using `AppBindings`
- Lazy initialization with `Get.lazyPut()` and `fenix: true`
- Controllers, repositories, and use cases auto-injected

## Database Schema (Current Version 5)

**Parameters Table** - Stores parameter definitions
```sql
CREATE TABLE parameters (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,                    -- Parameter name
  data_type TEXT NOT NULL,               -- Number, Text, Rating, YesNo
  unit TEXT,                            -- Optional unit (e.g. "hours", "kg")
  scale_options TEXT,                   -- JSON array for Rating scales
  is_preset INTEGER DEFAULT 0,          -- 1 if preset parameter
  is_enabled INTEGER DEFAULT 1,         -- 1 if enabled/active
  sort_order INTEGER DEFAULT 0,         -- Display order
  icon_name TEXT                        -- Icon name for presets
);
```

**Daily Records Table** - Stores daily entries
```sql
CREATE TABLE daily_records (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL,                   -- ISO 8601 date format
  dataValues TEXT NOT NULL,            -- JSON map {parameter_id: value}
  comments TEXT                        -- JSON map {parameter_id: comment}
);
```

**Supported Data Types**: `Number`, `Text`, `Rating`, `YesNo` (Date/Time removed per requirements)

**Migration System**: Automated schema upgrades in `DatabaseHelper._onUpgrade()`

## Development Workflow

**CRITICAL: Always follow this sequence when making changes:**

1. **Run `flutter pub get`** - Ensure dependencies are current
2. **Understand the codebase** - Read relevant files before making changes
3. **Make incremental changes** - Implement one feature at a time
4. **Test immediately** - Run `flutter run --debug` after each change
5. **Run static analysis** - Execute `flutter analyze` before commits
6. **Test functionality** - Use manual testing and automated tests
7. **Commit with descriptive messages** - Follow conventional commit format

**Key Rules:**
- NEVER skip `flutter analyze` - it catches critical issues early
- ALWAYS test on a real device/simulator, not just analysis
- Use hot reload (`r`) during development for faster iteration
- Run full test suite with `flutter test` before major commits

## Core Data Models

**Parameter Model** (`lib/models/parameter.dart`)
```dart
class Parameter {
  final int? id;
  final String name;              // Parameter name
  final String dataType;         // Number, Text, Rating, YesNo
  final String? unit;             // Optional unit
  final List<String>? scaleOptions; // For Rating type
  final bool isPreset;            // True for default parameters
  final bool isEnabled;           // Can be disabled without deletion
  final int sortOrder;            // Display order
  final String? iconName;         // Icon for preset parameters
  final DateTime createdAt;
}
```

**DailyRecord Model** (`lib/models/daily_record.dart`)
```dart
class DailyRecord {
  final int? id;
  final DateTime date;
  final Map<String, dynamic> dataValues;  // {parameter_id: value}
  final Map<String, String> comments;     // {parameter_id: comment}
}
```

**Preset Parameters System**
- 15 default parameters created automatically on first launch
- Managed by `PresetParametersService` in `lib/domain/services/`
- Icons from Material Design (bedtime, medication, work, etc.)
- Cannot be deleted, only disabled via `is_enabled` flag

## Key Controllers & Their Responsibilities

**HomeController** (`lib/domain/controllers/home_controller.dart`)
- Calendar logic and date selection
- Streak calculations and monthly statistics
- Manages filled dates and counters
- Reactive variables: `selectedDate`, `currentMonth`, `filledDates`, `consecutiveDays`

**DataEntryController** (`lib/domain/controllers/data_entry_controller.dart`)
- Data input flow management
- Parameter value collection and validation
- Integration with HomeController for date synchronization

**ParameterController** (`lib/domain/controllers/parameter_controller.dart`)
- Parameter CRUD operations
- Preset parameter management
- Parameter enabling/disabling

**DailyRecordController** (`lib/domain/controllers/daily_record_controller.dart`)
- Daily record CRUD operations
- CSV export functionality
- Data sharing capabilities

## Critical File Locations

**Core Logic:**
- `lib/data/database_helper.dart` - SQLite setup and migrations
- `lib/domain/services/preset_parameters_service.dart` - Default parameters
- `lib/utils/csv_exporter.dart` - Data export functionality

**UI Components:**
- `lib/presentation/screens/main_navigation_screen.dart` - Main app navigation
- `lib/presentation/widgets/calendar_widget.dart` - Calendar component
- `lib/presentation/screens/data_entry_screen.dart` - Data input interface
- `lib/presentation/theme/app_theme.dart` - Material Design 3 configuration

## Dependencies & Packages

**Core Dependencies** (already configured in `pubspec.yaml`):
```yaml
flutter: sdk                    # Flutter framework
get: ^4.6.5                    # State management (USE THIS)
sqflite: ^2.0.0               # SQLite database
path_provider: ^2.0.14        # File system access
share_plus: ^7.2.1           # Native sharing capabilities
intl: ^0.18.0                # Internationalization/date formatting
cupertino_icons: ^1.0.8      # iOS-style icons

# Dev dependencies
flutter_lints: ^5.0.0        # Static analysis rules
sqflite_common_ffi: ^2.0.0   # SQLite testing support
```

**NEVER add new dependencies without checking if existing ones can be used**

## Critical Development Guidelines

**Database Operations:**
- Always use try-catch blocks around database operations
- Test database migrations with version upgrades
- Use proper transaction handling for bulk operations

**GetX State Management:**
- Use `.obs` for reactive variables that trigger UI updates
- Call `.update()` on complex objects to notify listeners
- Avoid rebuilding entire UI - use selective GetX updates

**Error Handling:**
```dart
try {
  await databaseOperation();
} catch (e) {
  print('Operation failed: $e');
  // Show user-friendly error message
}
```

**Performance Tips:**
- Use `Get.lazyPut()` for dependency injection to avoid unnecessary initialization
- Implement proper loading states with reactive variables
- Use `Obx()` widgets for targeted UI updates, not `GetBuilder()`

## Testing Strategy & Project Structure

**Testing Areas:**
- `test/models/` - Data model validation and serialization
- `test/controllers/` - Business logic and state management  
- `test/data/` - Database operations and DAOs
- `test/domain/use_cases/` - Business use cases
- `test/presentation/` - UI components and screens

**Project Structure:**
```
lib/
├── main.dart                    # App entry + dependency injection
├── models/                      # Parameter, DailyRecord models
├── data/                        # Data access layer
│   ├── database_helper.dart     # SQLite setup & migrations
│   ├── local_database/          # DAOs for database ops
│   └── repositories/            # Repository pattern implementation
├── domain/                      # Business logic layer  
│   ├── controllers/             # GetX controllers
│   ├── use_cases/              # Business operations
│   └── services/               # Application services
├── presentation/               # UI layer
│   ├── screens/               # App screens/pages
│   ├── widgets/               # Reusable components
│   └── theme/                 # Material Design 3 theme
└── utils/                     # Utilities (CSV export, etc.)
```