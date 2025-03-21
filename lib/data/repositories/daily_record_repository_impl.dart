import '../local_database/daily_record_dao.dart';
import '../../models/daily_record.dart';
import 'daily_record_repository.dart';

class DailyRecordRepositoryImpl implements DailyRecordRepository {
  final DailyRecordDao _dailyRecordDao = DailyRecordDao(); // Создаем экземпляр DailyRecordDao

  @override
  Future<int> insertDailyRecord(DailyRecord dailyRecord) async {
    return await _dailyRecordDao.insertDailyRecord(dailyRecord); // Делегируем в DAO
  }

  @override
  Future<DailyRecord?> getDailyRecord(int id) async {
    return await _dailyRecordDao.getDailyRecord(id); // Делегируем в DAO
  }

  @override
  Future<DailyRecord?> getDailyRecordByDate(DateTime date) async {
    return await _dailyRecordDao.getDailyRecordByDate(date); // Делегируем в DAO
  }

  @override
  Future<List<DailyRecord>> getAllDailyRecords() async {
    return await _dailyRecordDao.getAllDailyRecords(); // Делегируем в DAO
  }

  @override
  Future<int> updateDailyRecord(DailyRecord dailyRecord) async {
    return await _dailyRecordDao.updateDailyRecord(dailyRecord); // Делегируем в DAO
  }

  @override
  Future<int> deleteDailyRecord(int id) async {
    return await _dailyRecordDao.deleteDailyRecord(id); // Делегируем в DAO
  }
}