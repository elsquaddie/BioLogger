import 'package:sqflite/sqflite.dart';
import '../../models/daily_record.dart';
import 'package:biologgs/data/database_helper.dart';
import 'dart:convert'; // Для работы с JSON

class DailyRecordDao {
final DatabaseHelper _databaseHelper = DatabaseHelper.instance; // Получаем экземпляр DatabaseHelper

// Метод для добавления новой ежедневной записи в базу данных
Future<int> insertDailyRecord(DailyRecord dailyRecord) async {
Database? db = await _databaseHelper.database;

// First try to find existing record for this date
String dateString = dailyRecord.date.toIso8601String().split('T')[0];

// Delete any existing records for this date
await db!.delete(
  DatabaseHelper.tableDailyRecords,
  where: "date = ?",
  whereArgs: [dateString]
);

Map<String, dynamic> values = dailyRecord.toJson();
print("DailyRecordDao: Saving new record for date: $dateString");
print("DailyRecordDao: Values before JSON encode: ${values['dataValues']}");
print("DailyRecordDao: Comments before JSON encode: ${values['comments']}");
values['dataValues'] = jsonEncode(values['dataValues']);
values['comments'] = jsonEncode(values['comments']);

return await db.insert(
  DatabaseHelper.tableDailyRecords,
  values,
);
}

// Метод для получения ежедневной записи по ID
Future<DailyRecord?> getDailyRecord(int id) async {
Database? db = await _databaseHelper.database;
List<Map> maps = await db!.query(
DatabaseHelper.tableDailyRecords,
columns: [
DatabaseHelper.columnDailyRecordId,
DatabaseHelper.columnDailyRecordDate,
DatabaseHelper.columnDailyRecordDataValues,
DatabaseHelper.columnDailyRecordComments,
],
where: '${DatabaseHelper.columnDailyRecordId} = ?',
whereArgs: [id],
);

if (maps.isNotEmpty) {
  Map<String, dynamic> recordMap = Map<String, dynamic>.from(maps.first);
  // Десериализуем dataValues из JSON строки обратно в Map<String, dynamic>
  recordMap[DatabaseHelper.columnDailyRecordDataValues] = jsonDecode(recordMap[DatabaseHelper.columnDailyRecordDataValues]);
  // Десериализуем comments из JSON строки обратно в Map<String, String>
  if (recordMap[DatabaseHelper.columnDailyRecordComments] != null && recordMap[DatabaseHelper.columnDailyRecordComments].isNotEmpty) {
    recordMap[DatabaseHelper.columnDailyRecordComments] = jsonDecode(recordMap[DatabaseHelper.columnDailyRecordComments]);
  } else {
    recordMap[DatabaseHelper.columnDailyRecordComments] = <String, String>{};
  }
  return DailyRecord.fromJson(recordMap);
}
return null;
}

// Метод для получения ежедневной записи по дате
Future<DailyRecord?> getDailyRecordByDate(DateTime date) async {
Database? db = await _databaseHelper.database;
String dateString = date.toIso8601String().split('T')[0];

print("DailyRecordDao: Searching for record with date: $dateString");

List<Map> maps = await db!.query(
  DatabaseHelper.tableDailyRecords,
  where: "date = ?", // Changed from substr to direct comparison
  whereArgs: [dateString],
  orderBy: "id DESC", // Get the latest record if multiple exist
  limit: 1 // Only get one record
);

print("DailyRecordDao: Raw query result: $maps");

if (maps.isNotEmpty) {
  Map<String, dynamic> recordMap = Map<String, dynamic>.from(maps.first);
  recordMap[DatabaseHelper.columnDailyRecordDataValues] = 
      jsonDecode(recordMap[DatabaseHelper.columnDailyRecordDataValues]);
  // Десериализуем comments из JSON строки обратно в Map<String, String>
  if (recordMap[DatabaseHelper.columnDailyRecordComments] != null && recordMap[DatabaseHelper.columnDailyRecordComments].isNotEmpty) {
    recordMap[DatabaseHelper.columnDailyRecordComments] = jsonDecode(recordMap[DatabaseHelper.columnDailyRecordComments]);
  } else {
    recordMap[DatabaseHelper.columnDailyRecordComments] = <String, String>{};
  }
  return DailyRecord.fromJson(recordMap);
}
return null;
}

// Метод для получения всех ежедневных записей
Future<List<DailyRecord>> getAllDailyRecords() async {
Database? db = await _databaseHelper.database;
List<Map> maps = await db!.query(DatabaseHelper.tableDailyRecords);

if (maps.isNotEmpty) {
  return maps.map((map) {
     Map<String, dynamic> recordMap = Map<String, dynamic>.from(map);
    // Десериализуем dataValues из JSON строки обратно в Map<String, dynamic>
    recordMap[DatabaseHelper.columnDailyRecordDataValues] = jsonDecode(recordMap[DatabaseHelper.columnDailyRecordDataValues]);
    // Десериализуем comments из JSON строки обратно в Map<String, String>
    if (recordMap[DatabaseHelper.columnDailyRecordComments] != null && recordMap[DatabaseHelper.columnDailyRecordComments].isNotEmpty) {
      recordMap[DatabaseHelper.columnDailyRecordComments] = jsonDecode(recordMap[DatabaseHelper.columnDailyRecordComments]);
    } else {
      recordMap[DatabaseHelper.columnDailyRecordComments] = <String, String>{};
    }
    return DailyRecord.fromJson(recordMap);
  }).toList();
}
return [];
}

// Метод для обновления ежедневной записи
Future<int> updateDailyRecord(DailyRecord dailyRecord) async {
Database? db = await _databaseHelper.database;
Map<String, dynamic> values = dailyRecord.toJson();

// Сериализуем dataValues и comments в JSON строку
values['dataValues'] = jsonEncode(values['dataValues']);
values['comments'] = jsonEncode(values['comments']);

return await db!.update(
  DatabaseHelper.tableDailyRecords,
  values,
  where: '${DatabaseHelper.columnDailyRecordId} = ?',
  whereArgs: [dailyRecord.id],
);
}

// Метод для удаления ежедневной записи по ID
Future<int> deleteDailyRecord(int id) async {
Database? db = await _databaseHelper.database;
return await db!.delete(
DatabaseHelper.tableDailyRecords,
where: '${DatabaseHelper.columnDailyRecordId} = ?',
whereArgs: [id],
);
}
}