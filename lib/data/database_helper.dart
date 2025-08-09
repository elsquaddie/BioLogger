import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const databaseName = "biolog_database.db";
  static const databaseVersion = 4;

  // Имена таблиц
  static const tableParameters = 'parameters';
  static const tableDailyRecords = 'daily_records';

  // Поля таблицы parameters
  static const columnParameterId = 'id';
  static const columnParameterName = 'name';
  static const columnParameterDataType = 'data_type';
  static const columnParameterUnit = 'unit';
  static const columnParameterScaleOptions = 'scale_options'; //  Здесь нужно будет хранить JSON или как-то сериализовать List<String>

  // Поля таблицы daily_records
  static const columnDailyRecordId = 'id';
  static const columnDailyRecordDate = 'date';
  static const columnDailyRecordDataValues = 'dataValues'; // Changed from 'data_values' to 'dataValues'
  static const columnDailyRecordComments = 'comments';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), databaseName); // Путь к базе данных
    print("Database path: $path"); // <--- ДОБАВЬ ЭТУ СТРОКУ: Логирование пути
    print("Requesting database version: $databaseVersion");
    return await openDatabase(
      path,
      version: databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Создание таблицы parameters
    await db.execute('''
      CREATE TABLE $tableParameters (
        $columnParameterId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnParameterName TEXT NOT NULL,
        $columnParameterDataType TEXT NOT NULL,
        $columnParameterUnit TEXT,
        $columnParameterScaleOptions TEXT
      )
    ''');

    // Создание таблицы daily_records с обновленным именем колонки
    await db.execute('''
      CREATE TABLE daily_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        dataValues TEXT NOT NULL,
        comments TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print("Upgrading database from version $oldVersion to $newVersion");
    
    if (oldVersion < 3) {
      print("Applying migration for version 3: Adding column $columnParameterScaleOptions if not exists...");
      try {
        await db.execute('''
          ALTER TABLE $tableParameters ADD COLUMN $columnParameterScaleOptions TEXT
        ''');
        print("Column $columnParameterScaleOptions added or already exists.");
      } catch (e) {
        print("Error trying to add column $columnParameterScaleOptions: $e");
        var columns = await db.rawQuery('PRAGMA table_info($tableParameters)');
        bool exists = columns.any((col) => col['name'] == columnParameterScaleOptions);
        print("Column $columnParameterScaleOptions ${exists ? 'exists' : 'does not exist'}");
        if (!exists) {
          print("Failed to add column $columnParameterScaleOptions!");
        }
      }
    }

    if (oldVersion < 4) {
      print("Applying migration for version 4: Adding column $columnDailyRecordComments...");
      try {
        await db.execute('''
          ALTER TABLE $tableDailyRecords ADD COLUMN $columnDailyRecordComments TEXT
        ''');
        print("Column $columnDailyRecordComments added successfully.");
      } catch (e) {
        print("Error trying to add column $columnDailyRecordComments: $e");
        var columns = await db.rawQuery('PRAGMA table_info($tableDailyRecords)');
        bool exists = columns.any((col) => col['name'] == columnDailyRecordComments);
        print("Column $columnDailyRecordComments ${exists ? 'exists' : 'does not exist'}");
        if (!exists) {
          print("Failed to add column $columnDailyRecordComments!");
        }
      }
    }
  }
}