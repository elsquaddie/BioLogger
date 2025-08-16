import 'package:sqflite/sqflite.dart';
import '../../models/parameter.dart';
import 'package:biologgs/data/database_helper.dart';
import 'dart:convert'; // Для работы с JSON

class ParameterDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance; // Получаем экземпляр DatabaseHelper

  // Метод для добавления нового параметра в базу данных
  Future<int> insertParameter(Parameter parameter) async {
    Database db = await _databaseHelper.database;
    Map<String, dynamic> values = parameter.toJson();

    print("ParameterDao: Inserting parameter with values: $values");

    return await db.insert(
      DatabaseHelper.tableParameters,
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Метод для получения параметра по ID
  Future<Parameter?> getParameter(int id) async {
    Database db = await _databaseHelper.database;
    List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableParameters,
      where: '${DatabaseHelper.columnParameterId} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Parameter.fromJson(Map<String, dynamic>.from(maps.first));
    }
    return null;
  }

  // Метод для получения всех параметров
  Future<List<Parameter>> getAllParameters() async {
    print("ParameterDao: getAllParameters() - Start fetching all parameters from database...");

    Database db = await _databaseHelper.database;
    List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableParameters,
      orderBy: '${DatabaseHelper.columnParameterSortOrder} ASC, ${DatabaseHelper.columnParameterName} ASC',
    );

    print("ParameterDao: getAllParameters() - Raw data from database: $maps");

    if (maps.isNotEmpty) {
      try {
        final parameters = maps.map((map) {
          return Parameter.fromJson(Map<String, dynamic>.from(map));
        }).toList();
        print("ParameterDao: Successfully converted ${parameters.length} parameters");
        return parameters;
      } catch (e) {
        print("ParameterDao: Error converting database data to Parameters: $e");
        rethrow;
      }
    }

    print("ParameterDao: getAllParameters() - No parameters found in database table.");
    return [];
  }

  // Метод для получения только включенных параметров
  Future<List<Parameter>> getEnabledParameters() async {
    print("ParameterDao: getEnabledParameters() - Fetching enabled parameters...");

    Database db = await _databaseHelper.database;
    List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableParameters,
      where: '${DatabaseHelper.columnParameterIsEnabled} = ?',
      whereArgs: [1],
      orderBy: '${DatabaseHelper.columnParameterSortOrder} ASC, ${DatabaseHelper.columnParameterName} ASC',
    );

    if (maps.isNotEmpty) {
      try {
        final parameters = maps.map((map) {
          return Parameter.fromJson(Map<String, dynamic>.from(map));
        }).toList();
        print("ParameterDao: Successfully fetched ${parameters.length} enabled parameters");
        return parameters;
      } catch (e) {
        print("ParameterDao: Error converting enabled parameters: $e");
        rethrow;
      }
    }

    print("ParameterDao: No enabled parameters found");
    return [];
  }

  // Метод для получения только пресет параметров
  Future<List<Parameter>> getPresetParameters() async {
    Database db = await _databaseHelper.database;
    List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableParameters,
      where: '${DatabaseHelper.columnParameterIsPreset} = ?',
      whereArgs: [1],
      orderBy: '${DatabaseHelper.columnParameterSortOrder} ASC',
    );

    return maps.map((map) => Parameter.fromJson(Map<String, dynamic>.from(map))).toList();
  }

  // Метод для получения только пользовательских параметров
  Future<List<Parameter>> getUserParameters() async {
    Database db = await _databaseHelper.database;
    List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableParameters,
      where: '${DatabaseHelper.columnParameterIsPreset} = ?',
      whereArgs: [0],
      orderBy: '${DatabaseHelper.columnParameterSortOrder} ASC, ${DatabaseHelper.columnParameterName} ASC',
    );

    return maps.map((map) => Parameter.fromJson(Map<String, dynamic>.from(map))).toList();
  }

  // Метод для обновления параметра
  Future<int> updateParameter(Parameter parameter) async {
    Database db = await _databaseHelper.database;
    Map<String, dynamic> values = parameter.toJson();

    print("ParameterDao: Updating parameter ID ${parameter.id} with values: $values");
    return await db.update(
      DatabaseHelper.tableParameters,
      values,
      where: '${DatabaseHelper.columnParameterId} = ?',
      whereArgs: [parameter.id],
    );
  }

  // Метод для переключения состояния включен/выключен
  Future<int> toggleParameterEnabled(int id, bool isEnabled) async {
    Database db = await _databaseHelper.database;
    
    print("ParameterDao: Toggling parameter ID $id enabled state to $isEnabled");
    return await db.update(
      DatabaseHelper.tableParameters,
      {DatabaseHelper.columnParameterIsEnabled: isEnabled ? 1 : 0},
      where: '${DatabaseHelper.columnParameterId} = ?',
      whereArgs: [id],
    );
  }

  // Метод для обновления порядка сортировки
  Future<int> updateParameterSortOrder(int id, int sortOrder) async {
    Database db = await _databaseHelper.database;
    
    print("ParameterDao: Updating parameter ID $id sort order to $sortOrder");
    return await db.update(
      DatabaseHelper.tableParameters,
      {DatabaseHelper.columnParameterSortOrder: sortOrder},
      where: '${DatabaseHelper.columnParameterId} = ?',
      whereArgs: [id],
    );
  }

  // Метод для массового обновления порядка параметров (более эффективный)
  Future<void> updateParametersSortOrder(List<Parameter> parameters) async {
    Database db = await _databaseHelper.database;
    
    print("ParameterDao: Batch updating sort order for ${parameters.length} parameters");
    
    Batch batch = db.batch();
    for (int i = 0; i < parameters.length; i++) {
      final parameter = parameters[i];
      batch.update(
        DatabaseHelper.tableParameters,
        {DatabaseHelper.columnParameterSortOrder: i},
        where: '${DatabaseHelper.columnParameterId} = ?',
        whereArgs: [parameter.id],
      );
    }
    
    await batch.commit(noResult: true);
    print("ParameterDao: Batch sort order update completed");
  }

  // Метод для удаления параметра по ID (только для пользовательских параметров)
  Future<int> deleteParameter(int id) async {
    Database db = await _databaseHelper.database;
    
    // Проверяем, что это не пресет параметр
    List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableParameters,
      columns: [DatabaseHelper.columnParameterIsPreset],
      where: '${DatabaseHelper.columnParameterId} = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty && maps.first[DatabaseHelper.columnParameterIsPreset] == 1) {
      throw Exception('Cannot delete preset parameter. Use toggleParameterEnabled instead.');
    }
    
    print("ParameterDao: Deleting parameter ID $id");
    return await db.delete(
      DatabaseHelper.tableParameters,
      where: '${DatabaseHelper.columnParameterId} = ?',
      whereArgs: [id],
    );
  }

  // Метод для проверки наличия пресет параметров
  Future<bool> hasPresetParameters() async {
    Database db = await _databaseHelper.database;
    List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableParameters,
      columns: ['COUNT(*) as count'],
      where: '${DatabaseHelper.columnParameterIsPreset} = ?',
      whereArgs: [1],
    );
    
    int count = maps.first['count'] as int;
    print("ParameterDao: Found $count preset parameters");
    return count > 0;
  }

  // Метод для массовой вставки параметров (для инициализации пресетов)
  Future<void> insertPresetParameters(List<Parameter> presets) async {
    Database db = await _databaseHelper.database;
    
    print("ParameterDao: Inserting ${presets.length} preset parameters...");
    
    Batch batch = db.batch();
    for (Parameter preset in presets) {
      batch.insert(
        DatabaseHelper.tableParameters,
        preset.toJsonForInsert(), // Используем метод без created_at для совместимости
        conflictAlgorithm: ConflictAlgorithm.ignore, // Игнорируем если уже существует
      );
    }
    
    await batch.commit(noResult: true);
    print("ParameterDao: Preset parameters insertion completed");
  }
}