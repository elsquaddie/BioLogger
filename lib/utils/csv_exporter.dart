// lib/utils/csv_exporter.dart

import 'dart:io';
import 'dart:convert'; // Не используется напрямую, но может быть полезен
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart' as path_provider; // Используем псевдоним
import '../models/parameter.dart';
import '../models/daily_record.dart';
import 'package:intl/intl.dart';

class CsvExporter {
  // --- Метод convertToCsv остается без изменений ---
  static String convertToCsv(List<Parameter> parameters, List<DailyRecord> dailyRecords) {
    if (kDebugMode) {
      print('Starting CSV conversion with ${parameters.length} parameters and ${dailyRecords.length} records');
    }

    StringBuffer csvData = StringBuffer(); // Используем StringBuffer для эффективности
    final dateFormat = DateFormat('yyyy-MM-dd');

    // Add headers
    csvData.write('Дата,'); // Используем write вместо +=
    csvData.writeln(parameters.map((p) => _escapeCsvValue(p.name)).join(',')); // Экранируем заголовки на всякий случай

    // Process each record
    for (var record in dailyRecords) {
      try {
        // Add date
        csvData.write('${dateFormat.format(record.date)},');

        // Process values for each parameter
        final values = parameters.map((parameter) {
          try {
            final rawValues = record.dataValues;
            // Упрощенная проверка и получение значения
            final value = (rawValues is Map<String, dynamic>)
                ? rawValues[parameter.id.toString()] ?? ''
                : '';
            return _escapeCsvValue(value.toString()); // Экранируем значения
          } catch (e) {
            if (kDebugMode) {
              print('Error processing parameter ${parameter.id} for record ${record.date}: $e');
            }
            return ''; // Возвращаем пустое значение в случае ошибки для данного параметра
          }
        }).join(',');

        csvData.writeln(values); // Используем writeln для добавления \n
      } catch (e) {
        if (kDebugMode) {
          print('Error processing record for date ${record.date}: $e');
        }
        // Add empty values for this record if the whole record processing fails
        csvData.writeln(List.filled(parameters.length, '').join(','));
      }
    }
    if (kDebugMode) {
      print('CSV conversion finished.');
    }
    return csvData.toString();
  }

  // Вспомогательная функция для экранирования значений CSV (если они содержат запятые, кавычки или переводы строк)
  static String _escapeCsvValue(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      // Заменяем все кавычки на двойные кавычки и оборачиваем значение в кавычки
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }


  // --- НОВЫЙ Метод для создания временного файла ---
  static Future<String> createTemporaryCsvFile(String csvData) async {
    try {
      // Получаем временную директорию, специфичную для приложения
      final directory = await path_provider.getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      // Создаем уникальное имя файла
      final filePath = '${directory.path}/biolog_export_$timestamp.csv';
      final file = File(filePath);

      // Записываем данные в файл
      await file.writeAsString(csvData, encoding: utf8); // Указываем кодировку utf8

      if (kDebugMode) {
        print('Temporary CSV file created at: $filePath');
      }
      // Возвращаем путь к созданному файлу
      return filePath;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating temporary CSV file: $e');
      }
      // Пробрасываем ошибку выше, чтобы ее можно было обработать в контроллере
      rethrow;
    }
  }
}