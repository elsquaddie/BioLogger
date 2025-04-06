// lib/domain/controllers/daily_record_controller.dart

import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';  // Добавляем для Center и CircularProgressIndicator
import 'package:intl/intl.dart';        // Добавляем для DateFormat
import 'dart:io';
import 'dart:convert';

import '../../models/daily_record.dart';
import '../../data/repositories/daily_record_repository.dart';
// Убедись, что импорт для ParameterRepositoryImpl тоже есть, если он нужен для ExportDataUseCase
// import '../../data/repositories/parameter_repository_impl.dart';
import '../use_cases/export_data_use_case.dart';
import '../../utils/csv_exporter.dart';
import '../../models/parameter.dart'; // Уже есть

class DailyRecordController extends GetxController {
  final DailyRecordRepository _dailyRecordRepository;
  final ExportDataUseCase _exportDataUseCase;

  // Убедись, что конструктор получает все необходимые зависимости
  DailyRecordController(this._dailyRecordRepository, this._exportDataUseCase);

  final dailyRecords = <DailyRecord>[].obs;
  final selectedRecord = Rxn<DailyRecord>();

  // ... (onInit, loadDailyRecords, getRecordByDate, create/update/delete методы остаются без изменений) ...

  @override
  void onInit() {
    super.onInit();
    loadDailyRecords();
  }

  Future<void> loadDailyRecords() async {
    try {
      final loadedRecords = await _dailyRecordRepository.getAllDailyRecords();
      dailyRecords.assignAll(loadedRecords);
    } catch (e) {
      print("Error loading daily records: $e");
      // Возможно, стоит показать Snackbar пользователю
      Get.snackbar('Ошибка загрузки', 'Не удалось загрузить записи.');
    }
  }

  Future<DailyRecord?> getRecordByDate(DateTime date) async {
    try {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      return await _dailyRecordRepository.getDailyRecordByDate(normalizedDate);
    } catch (e) {
      print("Error getting record by date: $e");
      return null;
    }
  }

  Future<void> createDailyRecord(DailyRecord dailyRecord) async {
    try {
      final id = await _dailyRecordRepository.insertDailyRecord(dailyRecord);
      if (id != 0) {
        DailyRecord newRecord = dailyRecord.copyWith(id: id);
        dailyRecords.add(newRecord);
        dailyRecords.refresh(); // Обновляем список, если нужно немедленное отображение
      }
    } catch (e) {
      print("Error creating daily record: $e");
      Get.snackbar('Ошибка', 'Не удалось сохранить запись.');
    }
  }

  Future<void> updateDailyRecord(DailyRecord dailyRecord) async {
    try {
      await _dailyRecordRepository.updateDailyRecord(dailyRecord);
      final index = dailyRecords.indexWhere((record) => record.id == dailyRecord.id);
      if (index != -1) {
        dailyRecords[index] = dailyRecord;
        dailyRecords.refresh();
      }
    } catch (e) {
      print("Error updating daily record: $e");
      Get.snackbar('Ошибка', 'Не удалось обновить запись.');
    }
  }

  Future<void> deleteDailyRecord(int id) async {
    try {
      await _dailyRecordRepository.deleteDailyRecord(id);
      dailyRecords.removeWhere((record) => record.id == id);
    } catch (e) {
      print("Error deleting daily record: $e");
      Get.snackbar('Ошибка', 'Не удалось удалить запись.');
    }
  }


  // --- ОБНОВЛЕННЫЙ МЕТОД ЭКСПОРТА ---
  Future<void> exportDataAndShare() async { // Можно переименовать для ясности
    Get.dialog( // Показываем индикатор загрузки
      Center(child: CircularProgressIndicator()),
      barrierDismissible: false, // Нельзя закрыть диалог тапом вне его
    );

    try {
      // 1. Получаем данные для экспорта
      final (parameters, recordsToExport) = await _exportDataUseCase.execute();

      // Проверяем, есть ли что экспортировать
      if (recordsToExport.isEmpty || parameters.isEmpty) {
         if (Get.isDialogOpen ?? false) Get.back(); // Закрываем индикатор загрузки
         Get.snackbar('Информация', 'Нет данных для экспорта.');
         return;
      }

      // 2. Конвертируем данные в строку CSV
      final csvData = CsvExporter.convertToCsv(parameters, recordsToExport);

      // 3. Создаем временный файл CSV
      final csvFilePath = await CsvExporter.createTemporaryCsvFile(csvData);

      if (Get.isDialogOpen ?? false) Get.back(); // Закрываем индикатор загрузки ПЕРЕД открытием Share

      // 4. Вызываем диалог "Поделиться"
      final result = await Share.shareXFiles(
          [XFile(csvFilePath)], // Передаем путь к файлу как XFile
          subject: 'Экспорт данных BioLog (${DateFormat('yyyy-MM-dd').format(DateTime.now())})', // Тема (для email)
          text: 'Файл CSV с экспортированными данными из приложения BioLog.' // Сопроводительный текст
      );

      // 5. (Опционально) Обрабатываем результат шаринга
      if (result.status == ShareResultStatus.success) {
        print('Файл успешно отправлен/сохранен.');
        // Get.snackbar('Успех', 'Файл CSV готов к отправке.'); // Можно и не показывать, т.к. пользователь сам выбрал действие
      } else if (result.status == ShareResultStatus.dismissed) {
        print('Диалог "Поделиться" был закрыт пользователем.');
        // Можно показать сообщение, что экспорт отменен
         Get.snackbar('Отменено', 'Отправка файла была отменена.');
      } else {
         print('Отправка файла завершилась со статусом: ${result.status}');
         // Возможно, стоит показать общее сообщение об ошибке, если статус не success и не dismissed
         Get.snackbar('Ошибка отправки', 'Не удалось отправить файл.');
      }

      // 6. (Опционально, но рекомендуется) Удаляем временный файл после завершения операции
      // Хотя система должна сама чистить временные папки, лучше сделать это явно
      try {
        final tempFile = File(csvFilePath);
        if (await tempFile.exists()) {
          await tempFile.delete();
          print('Временный файл $csvFilePath удален.');
        }
      } catch (e) {
        print('Не удалось удалить временный файл $csvFilePath: $e');
        // Не критичная ошибка, можно просто залогировать
      }

    } catch (e) {
      print('Ошибка экспорта и отправки CSV: $e');
       if (Get.isDialogOpen ?? false) Get.back(); // Убедимся, что индикатор закрыт в случае ошибки
      Get.snackbar('Ошибка', 'Не удалось подготовить файл CSV для отправки.');
    }
  }

  // Старый метод можно удалить или оставить для справки
  /*
  Future<void> exportDataToCsv() async {
    // ... старый код ...
  }
  */
}