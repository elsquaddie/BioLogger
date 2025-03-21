import 'package:sqflite/sqflite.dart';
import '../../models/parameter.dart';
import 'package:biologgs/data/database_helper.dart';
import 'dart:convert'; // Для работы с JSON

class ParameterDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance; // Получаем экземпляр DatabaseHelper

  // Метод для добавления нового параметра в базу данных
  Future<int> insertParameter(Parameter parameter) async {
    Database? db = await _databaseHelper.database; // Получаем доступ к базе данных
    Map<String, dynamic> values = parameter.toJson(); // Преобразуем Parameter в Map для вставки в БД

    // Явно указываем порядок колонок и ключи values
    Map<String, dynamic> explicitValues = {
      'id': values['id'],
      'name': values['name'],
      'data_type': values['data_type'],
      'unit': values['unit'],
      'scale_options': values['scaleOptions'],
    };

    // Сериализуем scaleOptions в JSON строку, если они есть
    if (explicitValues['scale_options'] != null) {
      explicitValues['scale_options'] = jsonEncode(explicitValues['scale_options']);
    }

    return await db!.insert(
      DatabaseHelper.tableParameters,
      explicitValues,
    );
  }

  // Метод для получения параметра по ID
  Future<Parameter?> getParameter(int id) async {
    Database? db = await _databaseHelper.database;
    List<Map> maps = await db!.query(
      DatabaseHelper.tableParameters,
      columns: [
        DatabaseHelper.columnParameterId,
        DatabaseHelper.columnParameterName,
        DatabaseHelper.columnParameterDataType,
        DatabaseHelper.columnParameterUnit,
        DatabaseHelper.columnParameterScaleOptions,
      ],
      where: '${DatabaseHelper.columnParameterId} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      Map<String, dynamic> parameterMap = Map<String, dynamic>.from(maps.first);
      // Десериализуем scaleOptions из JSON строки обратно в List<String>
      if (parameterMap[DatabaseHelper.columnParameterScaleOptions] != null) {
        parameterMap[DatabaseHelper.columnParameterScaleOptions] = jsonDecode(parameterMap[DatabaseHelper.columnParameterScaleOptions]);
      }
      return Parameter.fromJson(Map<String, dynamic>.from(parameterMap)); // Преобразуем Map обратно в Parameter
    }
    return null; // Возвращаем null, если параметр не найден
  }

  // Метод для получения всех параметров
  Future<List<Parameter>> getAllParameters() async {
    print("ParameterDao: getAllParameters() - Start fetching all parameters from database...");

    Database? db = await _databaseHelper.database;
    List<Map> maps = await db!.query(DatabaseHelper.tableParameters);

    print("ParameterDao: getAllParameters() - SQL query executed: SELECT * FROM ${DatabaseHelper.tableParameters}");
    print("ParameterDao: getAllParameters() - Raw data from database: $maps"); // Added this line

    if (maps.isNotEmpty) {
      try {
        final parameters = maps.map((map) {
          Map<String, dynamic> parameterMap = Map<String, dynamic>.from(map);
          if (parameterMap[DatabaseHelper.columnParameterScaleOptions] != null) {
            parameterMap[DatabaseHelper.columnParameterScaleOptions] = 
                jsonDecode(parameterMap[DatabaseHelper.columnParameterScaleOptions]);
          }
          print("ParameterDao: Processing parameter: $parameterMap"); // Added this line
          return Parameter.fromJson(parameterMap);
        }).toList();
        print("ParameterDao: Successfully converted ${parameters.length} parameters");
        return parameters;
      } catch (e) {
        print("ParameterDao: Error converting database data to Parameters: $e"); // Added this line
        rethrow;
      }
    }

    print("ParameterDao: getAllParameters() - No parameters found in database table.");
    return [];
  }

  // Метод для обновления параметра
  Future<int> updateParameter(Parameter parameter) async {
    Database? db = await _databaseHelper.database;
    Map<String, dynamic> values = parameter.toJson();
     // Сериализуем scaleOptions в JSON строку, если они есть
    if (values['scaleOptions'] != null) {
      values['scaleOptions'] = jsonEncode(values['scaleOptions']);
    }

    return await db!.update(
      DatabaseHelper.tableParameters,
      values,
      where: '${DatabaseHelper.columnParameterId} = ?',
      whereArgs: [parameter.id],
    );
  }

  // Метод для удаления параметра по ID
  Future<int> deleteParameter(int id) async {
    Database? db = await _databaseHelper.database;
    return await db!.delete(
      DatabaseHelper.tableParameters,
      where: '${DatabaseHelper.columnParameterId} = ?',
      whereArgs: [id],
    );
  }
}