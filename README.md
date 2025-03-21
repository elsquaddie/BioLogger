# BioLogger

BioLogger is an application for convenient tracking of life quality data with the ability to export and analyze it later.

## Key Features

### Parameter Constructor
- Create custom parameters for tracking:
  - Name
  - Data type
  - Unit of measurement
- "Parameter Editor" screen for creating, viewing, and managing the parameter list.
- Save parameters in a local SQLite database.  
  ✅ **Implemented!**

### Daily Data Entry
- User-friendly interface for quick data entry for each parameter per day.
- "Data Entry" screen with sequential parameter input.
- Proper saving and loading of daily records with entered values in a local SQLite database.  
  ✅ **Implemented!** (basic functionality, UI/UX improvements planned)

### Local Data Storage
- Use of SQLite database for storing parameters and daily records on the user's device.  
  ✅ **Implemented!** (database structure and basic CRUD operations)
- Basic data export/import functionality in JSON format.  
  ⏳ **In progress** (next MVP task).

## Installation and Setup
1. Ensure you have [Flutter](https://flutter.dev/) installed.
2. Clone the repository:
   ```bash
   git clone https://github.com/elsquaddie/BioLogger.git
