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

    // Add headers - include parameter names and their comment columns
    csvData.write('Дата,');
    final headers = <String>[];
    for (var parameter in parameters) {
      headers.add(_escapeCsvValue(parameter.name));
      headers.add(_escapeCsvValue('${parameter.name} (комментарий)'));
    }
    csvData.writeln(headers.join(','));

    // Process each record
    for (var record in dailyRecords) {
      try {
        // Add date
        csvData.write('${dateFormat.format(record.date)},');

        // Process values and comments for each parameter
        final valuesAndComments = <String>[];
        for (var parameter in parameters) {
          try {
            final rawValues = record.dataValues;
            final rawComments = record.comments;
            
            // Get value
            final value = (rawValues is Map<String, dynamic>)
                ? rawValues[parameter.id.toString()] ?? ''
                : '';
            valuesAndComments.add(_escapeCsvValue(value.toString()));
            
            // Get comment
            final comment = (rawComments is Map<String, String>)
                ? rawComments[parameter.id.toString()] ?? ''
                : '';
            valuesAndComments.add(_escapeCsvValue(comment));
          } catch (e) {
            if (kDebugMode) {
              print('Error processing parameter ${parameter.id} for record ${record.date}: $e');
            }
            valuesAndComments.add(''); // Empty value
            valuesAndComments.add(''); // Empty comment
          }
        }
        final values = valuesAndComments.join(',');

        csvData.writeln(values); // Используем writeln для добавления \n
      } catch (e) {
        if (kDebugMode) {
          print('Error processing record for date ${record.date}: $e');
        }
        // Add empty values and comments for this record if the whole record processing fails
        csvData.writeln(List.filled(parameters.length * 2, '').join(','));
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