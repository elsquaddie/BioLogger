import 'package:get/get.dart';
import '../../models/daily_record.dart';
import '../../data/repositories/daily_record_repository.dart';
import '../../data/repositories/daily_record_repository_impl.dart';

class DailyRecordController extends GetxController {
  final DailyRecordRepository _dailyRecordRepository = DailyRecordRepositoryImpl(); // Репозиторий для ежедневных записей

  final dailyRecords = <DailyRecord>[].obs; // Observable список ежедневных записей
  final selectedRecord = Rxn<DailyRecord>(); // Observable для выбранной записи (например, для редактирования)

  @override
  void onInit() {
    super.onInit();
    loadDailyRecords(); // Загружаем записи при инициализации
  }

  Future<void> loadDailyRecords() async {
    try {
      final loadedRecords = await _dailyRecordRepository.getAllDailyRecords();
      dailyRecords.assignAll(loadedRecords);
    } catch (e) {
      // TODO: Обработка ошибок
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
      // TODO: Обработка ошибок
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
      // TODO: Обработка ошибок
      print("Error updating daily record: $e");
    }
  }

  Future<void> deleteDailyRecord(int id) async {
    try {
      await _dailyRecordRepository.deleteDailyRecord(id);
      dailyRecords.removeWhere((record) => record.id == id);
    } catch (e) {
      // TODO: Обработка ошибок
      print("Error deleting daily record: $e");
    }
  }
}