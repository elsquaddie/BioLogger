import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import '../models/parameter.dart';
import '../models/daily_record.dart';
import 'package:intl/intl.dart';

class CsvExporter {
  static String convertToCsv(List<Parameter> parameters, List<DailyRecord> dailyRecords) {
    if (kDebugMode) {
      print('Starting CSV conversion with ${parameters.length} parameters and ${dailyRecords.length} records');
    }
    
    String csvData = '';
    final dateFormat = DateFormat('yyyy-MM-dd');

    // Add headers
    csvData += 'Дата,${parameters.map((p) => p.name).join(',')}\n';

    // Process each record
    for (var record in dailyRecords) {
      try {
        // Add date
        csvData += '${dateFormat.format(record.date)},';
        
        // Process values for each parameter
        final values = parameters.map((parameter) {
          try {
            final rawValues = record.dataValues;
            Map<String, dynamic> valueMap;

            if (rawValues is Map<String, dynamic>) {
              valueMap = rawValues;
            } else {
              if (kDebugMode) {
                print('Unexpected data type for values: ${rawValues.runtimeType}');
              }
              valueMap = {};
            }

            // Get the value for this parameter
            final value = valueMap[parameter.id.toString()] ?? '';
            return value.toString();
          } catch (e) {
            if (kDebugMode) {
              print('Error processing parameter ${parameter.id}: $e');
            }
            return '';
          }
        }).join(',');

        csvData += '$values\n';
      } catch (e) {
        if (kDebugMode) {
          print('Error processing record for date ${record.date}: $e');
        }
        // Add empty values for this record
        csvData += '${','.padRight(parameters.length, ',')}\n';
      }
    }

    return csvData;
  }

  static Future<void> saveCsvFile(String csvData) async {
    try {
      final directory = await path_provider.getApplicationDocumentsDirectory(); // Исправлен вызов метода
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/biolog_export_$timestamp.csv');

      await file.writeAsString(csvData);
      if (kDebugMode) {
        print('CSV файл сохранен по пути: ${file.path}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка сохранения CSV файла: $e');
      }
      throw e;
    }
  }
}