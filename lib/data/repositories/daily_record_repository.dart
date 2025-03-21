import '../../models/daily_record.dart';

abstract class DailyRecordRepository {
  Future<int> insertDailyRecord(DailyRecord dailyRecord);
  Future<DailyRecord?> getDailyRecord(int id);
  Future<DailyRecord?> getDailyRecordByDate(DateTime date);
  Future<List<DailyRecord>> getAllDailyRecords();
  Future<int> updateDailyRecord(DailyRecord dailyRecord);
  Future<int> deleteDailyRecord(int id);
}