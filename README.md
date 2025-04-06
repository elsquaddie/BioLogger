# BioLogger 🌿

**A Flutter application for easily tracking personal metrics, life quality data, and exporting it for analysis.**

Define what matters to you, log your daily progress, and gain insights from your data.

<!-- TODO: Add a screenshot or GIF demonstrating the app's main screens (e.g., parameter list, data entry, home screen) -->
<!-- You can embed images using Markdown: ![Alt Text](path/to/image.png) -->

## ✨ Key Features (Current)

*   **📝 Custom Parameter Management:**
    *   Create parameters you want to track (e.g., Sleep Hours, Mood, Water Intake, Workout Duration).
    *   Define parameter details: Name, Data Type (Number, Text, Rating, Yes/No, Time, Date), Unit of Measurement.
    *   View, **Edit**, and **Delete** your parameters easily through a dedicated management screen.
*   **📅 Daily Data Logging:**
    *   Simple, sequential interface for entering values for each of your defined parameters daily.
*   **📤 Export & Share Data:**
    *   Generate a comprehensive CSV file containing all your parameters and daily entries.
    *   **Share the CSV file seamlessly** using the native system share dialog – send it to your messenger, email, cloud storage, or any compatible app without needing extra permissions.
*   **📱 Local & Private Storage:**
    *   All your data (parameters and daily records) is stored securely **on your device only** using an SQLite database.

## 🚀 Project Status

**✅ MVP (Minimum Viable Product) Complete!**

The core functionalities (parameter management, basic data entry, local storage, export/share) are implemented and working.

**🚧 Actively working on Post-MVP enhancements** focused on improving User Experience (UX) and adding more input flexibility.

## 🏗️ Architecture & Tech Stack

*   **Framework:** Flutter
*   **State Management:** GetX
*   **Database:** SQLite (via `sqflite` package)
*   **Architecture:** Layered Architecture (Presentation, Domain, Data)
    *   **Presentation:** UI Screens and GetX Controllers interacting with the Domain layer.
    *   **Domain:** Business logic, Use Cases (structure defined), Controllers.
    *   **Data:** Repositories (interfaces & implementations), DAOs (Data Access Objects), Database Helper (managing DB connection, creation, and **migrations**).
*   **Sharing:** `share_plus`
*   **Date Formatting:** `intl`
*   **File Paths:** `path_provider`

##  roadmap

### ⏳ Next Steps (Immediate Focus: Enhancing Data Entry)

*   **Improved Data Entry Screen UI/UX:** Make the data input process more intuitive and visually appealing.
*   **Dynamic Input Widgets:** Display appropriate input fields based on the parameter's data type:
    *   `Number`: Numeric input field (potentially with stepper +/- buttons).
    *   `Text`: Standard text input field.
    *   `Rating`: Interactive rating scale (e.g., 1-10 slider, tappable stars/emojis).
    *   `Yes/No`: Switch or Toggle Buttons.
    *   `Time`: Time picker dialog.
    *   `Date`: Date picker dialog.
*   **(Optional)** **Parameter Presets:** Allow users to add predefined sets of common parameters (e.g., "Wellness Basics", "Fitness Tracking") for a quicker start.

### 📅 Future Plans (Longer Term)

*   **Calendar View:** Navigate and view data entries visually on a calendar.
*   **Reminders:** Set reminders to log daily data.
*   **In-App Analytics & Visualization:** Basic charts and trends directly within the app.
*   **Improved Design:** Overall UI polish, potential theming.
*   **Data Import:** Import data from CSV or other formats.
*   **Cloud Sync & Backup (Optional):** Securely back up and sync data across devices.
*   **Advanced Features:** Voice input, deeper analytics, potential integrations.

## ⚙️ Installation and Setup

1.  Ensure you have [Flutter](https://flutter.dev/docs/get-started/install) installed (check with `flutter doctor`).
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
5.  Run the application on an emulator or connected device:
    ```bash
    flutter run
    ```

## 🙌 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check [issues page](<!-- TODO: Link to your issues page if public -->).

## 📄 License

<!-- TODO: Choose and add a license (e.g., MIT, Apache 2.0). Create a LICENSE file. -->
This project is licensed under the [Your License Name] License - see the `LICENSE` file for details.

---
