# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## My Persona

Act as a Senior Flutter Developer and UI/UX expert. My primary goal is to write clean, maintainable, and efficient code following Clean Architecture principles. I prioritize creating a smooth, intuitive, and visually appealing user experience. When implementing solutions, I think step-by-step, focusing on fixing the root cause of issues and ensuring new code is robust and well-tested.

## Project Overview

BioLogger is a Flutter application for tracking personal metrics and life quality data. It's built using Flutter, GetX for state management, and SQLite for local storage, following a Clean Architecture pattern. The app allows users to define custom parameters, log daily data, and export it to CSV.

## Key Principles for This Project

*   **User-Centricity:** All changes should improve the user's journey. Reduce clicks, provide clear feedback, and ensure the UI is intuitive.
*   **State Management with GetX:** Strictly use GetX reactive patterns (`.obs`, `Obx`) for UI updates. Ensure controllers are decoupled and managed through `Get.lazyPut`.
*   **Clean Architecture Adherence:** Respect the boundaries between the Presentation, Domain, and Data layers. UI logic belongs in screens/widgets, business logic in controllers/use cases, and data handling in repositories/DAOs.
*   **Code Quality:** Run `flutter analyze` before every commit. Write descriptive commit messages. Keep code DRY (Don't Repeat Yourself).

---
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

# Database debugging
flutter run --debug           # For examining SQLite operations with print statements
```

## Dependency Management
```bash
# Always run after pulling changes or modifying pubspec.yaml
flutter pub get

# Check for dependency issues
flutter pub deps
flutter pub outdated
```

## Testing Commands
```bash
# Run all tests
flutter test

# Run specific test categories
flutter test test/models/           # Data model tests
flutter test test/controllers/      # Business logic tests
flutter test test/presentation/     # UI component tests
flutter test test/data/            # Database operation tests
flutter test test/domain/use_cases/ # Business use case tests

# Run specific test file
flutter test test/domain/controllers/home_controller_test.dart

# Run tests with coverage
flutter test --coverage
```

## Common Development Issues & Solutions

**Database Migration Problems:**
- If database schema issues occur, run `flutter clean` and reinstall
- Check `DatabaseHelper._onUpgrade()` for migration logic
- Use `flutter run --debug` to see SQL operation logs

**GetX State Issues:**
- Ensure controllers use `.obs` for reactive variables
- Use `Obx()` widgets for UI updates, not `GetBuilder()`
- Verify dependency injection in `main.dart` AppBindings

**Navigation Parameter Bugs:**
- Always pass `parameter.id` not array indices when navigating
- Common bug: loop closures capturing wrong parameter reference
- Test navigation after any parameter list modifications

## ПРИОРИТЕТ: Исправление UI/UX и логических багов (Август 2025)

### 🎯 ПРИОРИТЕТНАЯ ЗАДАЧА: Обновление дизайна приложения (Редизайн)

**Цель:** Полностью обновить визуальный стиль приложения, чтобы он соответствовал макету в файле `layout.html`. Редизайн должен затронуть все экраны, обеспечив единый и современный пользовательский опыт. При этом вся существующая бизнес-логика, управление состоянием (GetX) и работа с базой данных должны остаться без изменений.

**Основной источник для дизайна:** `layout.html`

#### Что нужно учесть агенту, чтобы избежать ошибок:

1.  **Разделение логики и UI:** Строго придерживайся принципа разделения. Модифицируй только файлы в `lib/presentation/`. **Не изменяй** бизнес-логику в контроллерах (`lib/domain/controllers/`), use cases или репозиториях (`lib/data/`). Твоя задача — изменить "обертку" (UI), а не "начинку" (логику).
2.  **Сохранение GetX:** Вся реактивность должна по-прежнему управляться через GetX (`.obs`, `Obx`, `Get.find()`). Не заменяй эту систему.
3.  **Консистентность:** Ключ к успешному редизайну — создание переиспользуемых виджетов для общих элементов UI (карточки, кнопки, иконки), как описано в шаге 2, и их повсеместное использование.
4.  **Работа с пресетами:** Существующие 15 пресет-параметров в `PresetParametersService.dart` **не должны быть удалены**. Их нужно только обновить:
    *   Измени их `iconName` на строковые идентификаторы Material Icons, которые используются в `layout.html` (например, `people` в коде станет `'groups'`, `book` станет `'menu_book'` и т.д.).
    *   Убедись, что UI корректно отображает эти иконки в новом, едином стиле (`tint-box`).
5.  **Система иконок:** Новый дизайн требует унифицированного стиля для иконок (светло-зеленый фон, темно-зеленая иконка). Это должно быть реализовано через специальный виджет и применяться ко всем иконкам параметров в приложении. `ParameterIcons.dart` нужно будет адаптировать для работы с новыми строковыми именами иконок.
6.  **Пошаговое выполнение:** Следуй приведенным ниже шагам строго по порядку, чтобы обеспечить плавный и корректный переход на новый дизайн.

---

### Пошаговый план по редизайну приложения

#### Шаг 1: Обновление основной темы (`AppTheme.dart`)

1.  **Извлеки цветовую палитру** из CSS-переменных в `<style>` теге файла `layout.html`:
    *   `--brand: #88A874` (основной зеленый)
    *   `--brand-700: #6f8d5f` (темно-зеленый для hover-эффектов)
    *   `--tint: #e8f1e3` (светло-зеленый для фона иконок)
    *   `background: #f7faf9` (основной фон приложения)
2.  **Обнови `AppTheme.lightTheme`** в `lib/presentation/theme/app_theme.dart`:
    *   Установи `primary` цвет в `#88A874`.
    *   Установи `scaffoldBackgroundColor` и `backgroundColor` в `#f7faf9`.
    *   Обнови цвета для кнопок, AppBar и других элементов в соответствии с новым стилем.
    *   Изучи `layout.html` на предмет шрифтов (используется "Inter") и убедись, что `textTheme` в `AppTheme` соответствует этому.
3.  **Удали старые, неиспользуемые цветовые константы**, чтобы избежать путаницы.

#### Шаг 2: Создание переиспользуемых UI-компонентов

Чтобы обеспечить консистентность, создай новые виджеты для основных элементов дизайна. Помести их в новую директорию `lib/presentation/widgets/ui_components/`.

1.  **`AppCard.dart`**: Создай виджет, который стилизует `Card` в соответствии с классом `.card` из HTML (белый фон, `borderRadius: 1.25rem`, тень `box-shadow`, рамка `border`).
2.  **`PrimaryButton.dart` и `OutlineButton.dart`**: Создай виджеты-обертки для `ElevatedButton` и `OutlinedButton`, которые будут применять стили из `.btn-primary` и `.btn-outline` соответственно.
3.  **`TintedIconBox.dart`**: Это **ключевой** компонент. Создай виджет, который реализует стиль `.tint-box`. Он должен принимать `IconData` и отображать его внутри `Container` с фоном `--tint` (`#e8f1e3`) и цветом иконки `--brand` (`#88A874`), а также с закругленными углами.

#### Шаг 3: Адаптация системы иконок

1.  **Обнови пресеты:** Открой `lib/domain/services/preset_parameters_service.dart`. Пройдись по списку `getDefaultParameters` и замени строковые значения `iconName` на актуальные имена из Material Icons, используемые в `layout.html`. Например:
    *   `Оценка социальности` (`people`) -> `iconName: 'groups'`
    *   `Воспоминания обо дне` (`book`) -> `iconName: 'menu_book'`
    *   И так далее для всех 15 пресетов, сверяясь с иконками в `layout.html`.
2.  **Адаптируй `ParameterIcons.dart`**: Убедись, что метод `getIcon` корректно работает с новыми строковыми именами иконок. Возможно, потребуется обновить карту `presetIcons`.

#### Шаг 4: Редизайн экранов (Screen-by-Screen)

Теперь, используя созданные компоненты, обнови каждый экран.

1.  **`MainNavigationScreen.dart`**:
    *   Обнови `BottomNavigationBar`, чтобы он соответствовал секции `<nav>` в макете. Используй `Material Icons` и настрой цвета для активного (`tab-active`) и неактивного состояний.

2.  **`HomeScreen.dart`**:
    *   Замени `AppBar` на кастомный `header` с фоном `var(--brand)`.
    *   Перестрой `CalendarWidget` для соответствия новому дизайну. Особое внимание удели стилям дней: `.day-completed`, `.day-selected`, `.day-today`.
    *   Секцию "Статистика" переделай с использованием `AppCard` и нового виджета `TintedIconBox` для иконок `local_fire_department` и `event`.
    *   Кнопку "Добавить запись" замени на свой новый виджет `PrimaryButton`.

3.  **`DataEntryScreen.dart`**:
    *   Полностью переработай UI, ориентируясь на экраны `screen-entry-list`, `screen-entry-number`, `screen-entry-rating`, `screen-entry-text`.
    *   **Список параметров (`_buildListView`)**: Каждый элемент списка (`_buildParameterListItem`) должен теперь выглядеть как в макете, используя `TintedIconBox`.
    *   **Экраны ввода (`_buildPageView`)**:
        *   Верхний `header` и `progress` бар должны быть стилизованы под макет.
        *   Карточка с названием параметра должна использовать `TintedIconBox` для иконки и иметь крупный заголовок.
        *   Поля ввода (`TextFormField`, `Slider` и др.) должны быть стилизованы в соответствии с `app_theme.dart`.
        *   Нижние кнопки навигации должны использовать `PrimaryButton` и `OutlineButton`.

4.  **`MetricsScreen.dart` и `ParameterListWidget.dart`**:
    *   **Экран метрик**: Обнови карточки и кнопки, используя `AppCard` и `PrimaryButton`. Заглушки для будущих функций должны выглядеть как в секции "Статистика и анализ" макета.
    *   **Список параметров (`ParameterListWidget`)**: Это критически важный экран. Полностью переделай `_buildParameterTile`, чтобы он соответствовал элементу списка на экране `screen-manage`. Используй `TintedIconBox`, `drag_indicator`, `Switch` и `PopupMenuButton` (`more_vert`), стилизованные под макет.

5.  **`SettingsScreen.dart`**:
    *   Переделай экран, используя `AppCard` для секций и `PrimaryButton` для кнопки экспорта. Все карточки должны включать `TintedIconBox`.

6.  **`ParameterCreateScreen.dart` / `ParameterEditScreen.dart`**:
    *   Обнови UI этих экранов, чтобы он соответствовал `screen-step1` и `screen-step2`.
    *   Особое внимание удели превью карточки параметра — оно должно показывать новый дизайн.
    *   Реализуй всплывающее окно выбора иконки (`iconSheet`), как показано в макете.

#### Шаг 5: Финальная проверка

1.  **Запусти приложение** и пройдись по всем экранам, сравнивая их с `layout.html`. Убедись, что отступы, шрифты, цвета и размеры соответствуют макету.
2.  **Проверь всю функциональность**:
    *   Создание, редактирование и удаление пользовательских параметров.
    *   Включение/выключение пресет-параметров.
    *   Ввод данных всех типов (число, текст, рейтинг) за разные дни.
    *   Корректное отображение статистики на главном экране.
    *   Экспорт данных в CSV.
    *   Перетаскивание параметров в списке для изменения порядка.
3.  **Выполни `flutter analyze`**, чтобы убедиться в отсутствии статических ошибок в коде.

---

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
path: ^1.8.0                  # Path utilities
path_provider: ^2.0.14        # File system access
share_plus: ^7.2.1           # Native sharing capabilities
intl: ^0.18.0                # Internationalization/date formatting
cupertino_icons: ^1.0.8      # iOS-style icons

# Dev dependencies
flutter_lints: ^5.0.0        # Static analysis rules
sqflite_common_ffi: ^2.0.0   # SQLite testing support
```

**NEVER add new dependencies without checking if existing ones can be used**

## Project-Specific Conventions

**File Organization:**
- Follow Clean Architecture: UI logic in `presentation/`, business logic in `domain/`, data access in `data/`
- Use `_` prefix for private methods and variables
- Group related files in subdirectories (e.g., `use_cases/`, `controllers/`)

**Naming Conventions:**
- Controllers: `*Controller` (e.g., `HomeController`, `DataEntryController`)
- Use Cases: `*UseCase` (e.g., `CalculateStreakUseCase`)
- DAOs: `*Dao` (e.g., `ParameterDao`, `DailyRecordDao`)
- Models: Plain class names (e.g., `Parameter`, `DailyRecord`)

**Code Style:**
- Use descriptive variable names (`selectedDate` not `date`)
- Add print statements for debugging complex flows (remove in production)
- Prefer composition over inheritance
- Always handle exceptions in database operations

**Russian Language:**
- UI text and comments can be in Russian as per project requirements
- Variable/method names should remain in English
- Error messages and debug prints can be in Russian

## Critical Development Guidelines

**Database Operations:**
- Always use try-catch blocks around database operations
- Test database migrations with version upgrades
- Use proper transaction handling for bulk operations
- Database operations are logged with print statements - monitor console during `flutter run --debug`

**GetX State Management:**
- Use `.obs` for reactive variables that trigger UI updates
- Call `.update()` on complex objects to notify listeners
- Avoid rebuilding entire UI - use selective GetX updates
- CRITICAL: When passing parameters in navigation, ensure correct ID/object is captured (common bug source)

**Navigation & Parameter Passing:**
- Always use parameter.id (not array index) when navigating to edit screens
- Verify closure variable capture in loop-based UI generation (for bug in navigation)
- Test navigation thoroughly after any parameter list changes

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