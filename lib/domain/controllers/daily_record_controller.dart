import 'package:get/get.dart';
import '../../models/daily_record.dart';
import '../../data/repositories/daily_record_repository.dart';
import '../../data/repositories/daily_record_repository_impl.dart';
import '../use_cases/export_data_use_case.dart';
import '../../utils/csv_exporter.dart';
import '../../models/parameter.dart';

class DailyRecordController extends GetxController {
  final DailyRecordRepository _dailyRecordRepository;
  final ExportDataUseCase _exportDataUseCase;

  DailyRecordController(this._dailyRecordRepository, this._exportDataUseCase);

  final dailyRecords = <DailyRecord>[].obs;
  final selectedRecord = Rxn<DailyRecord>();

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
      }
    } catch (e) {
      print("Error creating daily record: $e");
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
    }
  }

  Future<void> deleteDailyRecord(int id) async {
    try {
      await _dailyRecordRepository.deleteDailyRecord(id);
      dailyRecords.removeWhere((record) => record.id == id);
    } catch (e) {
      print("Error deleting daily record: $e");
    }
  }

  Future<void> exportDataToCsv() async {
    try {
      final (parameters, dailyRecords) = await _exportDataUseCase.execute();
      final csvData = CsvExporter.convertToCsv(parameters, dailyRecords);
      await CsvExporter.saveCsvFile(csvData);
      Get.snackbar('Успех', 'Данные экспортированы в CSV файл.\nПроверьте консоль для пути к файлу.');
    } catch (e) {
      print('Ошибка экспорта CSV: $e');
      Get.snackbar('Ошибка', 'Не удалось экспортировать данные в CSV');
    }
  }
}