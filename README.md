# BioLogger app

**Application for tracking life quality data with export and analysis capabilities.**

**Current Status: MVP (Minimum Viable Product) - ✅ Completed!**

**MVP Key Features:**

### 1. Parameter Constructor
- Create custom parameters for tracking:
  - Name
  - Data type
  - Unit of measurement
    
- "Parameter Editor" screen for creating and viewing the parameter list.
- Save parameters in a local SQLite database.
  ✅ **Implemented!**

### 2. Daily Data Entry
- User-friendly interface for quick data entry for each parameter per day.
- "Data Entry" screen with sequential parameter input.
- Saving daily records with entered values in a local SQLite database.
  ✅ **Implemented!** (basic functionality, UI/UX improvements planned for Post-MVP)

### 3. Local Storage and Data Export
- Utilizing an SQLite database for local storage of parameters and daily records on the user's device.
  ✅ **Implemented!** (database structure and basic CRUD operations)
- **Data Export to CSV format.** Ability to export all data to a CSV file for further analysis and processing.
  ✅ **Implemented!** (basic CSV export functionality)

## Post-MVP Plans (after the first version release):

**Focus on improving user experience and expanding functionality:**

1.  **Enhanced "Parameter Editor":**
    *   Editing existing parameters.
    *   Deleting parameters.

2.  **Improved and User-Friendly "Data Entry":**
    *   Enhanced UI/UX of the "Data Entry" screen.
    *   Various input field types based on parameter type (numeric fields, sliders, switches, select boxes, etc.).
    *   10-point rating scale (potentially with emojis) for "Rating" type parameters.
    *   Parameter Presets: a set of pre-defined parameters for a quick start (e.g., "Sleep", "Activity", "Mood", etc.).

3.  **Design and UI/UX:**
    *   Overall application design improvement.
    *   Potential addition of emojis and images to enhance visual appeal.

**Functionality planned for later Post-MVP stages:**

*   Calendar view for data browsing.
*   Reminders to fill in data.
*   Data analytics and visualization within the application.
*   Data import from other formats (JSON, Google Sheets).
*   Cloud synchronization and data backup.
*   Advanced design and themes.
*   Future potential integration of simple analytical functions based on neural networks.

## Installation and Setup

1.  Ensure you have [Flutter](https://flutter.dev/) installed.
2.  Clone the repository:
    ```bash
    git clone [Your Repository URL]
    ```
3.  Navigate to the project directory:
    ```bash
    cd BioLog
    ```
4.  Install dependencies:
    ```bash
    flutter pub get
    ```
5.  Run the application:
    ```bash
    flutter run
    ```

**"BioLog" application is developed using Flutter and follows a layered architecture (Presentation, Domain, Data Layer) to ensure scalability and maintainability.**
