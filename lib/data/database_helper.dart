import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const databaseName = "biolog_database.db";
  static const databaseVersion = 2;

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

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database; // Если база данных уже существует, возвращаем ее
    _database = await _initDatabase(); // Инициализируем, если нет
    return _database;
  }

Future<Database> _initDatabase() async {
  String path = join(await getDatabasesPath(), databaseName); // Путь к базе данных
  print("Database path: $path"); // <--- ДОБАВЬ ЭТУ СТРОКУ: Логирование пути
  return await openDatabase(path,
      version: databaseVersion,
      onCreate: _onCreate);
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
        dataValues TEXT NOT NULL
      )
    ''');
  }
}