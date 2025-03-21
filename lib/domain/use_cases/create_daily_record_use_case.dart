import '../../models/daily_record.dart';
import '../../data/repositories/daily_record_repository.dart';
import '../../data/repositories/daily_record_repository_impl.dart';

class CreateDailyRecordUseCase {
  final DailyRecordRepository _dailyRecordRepository = DailyRecordRepositoryImpl();

  Future<int> execute(DailyRecord dailyRecord) async {
    // Здесь может быть бизнес-логика перед созданием ежедневной записи
    return await _dailyRecordRepository.insertDailyRecord(dailyRecord);
  }
}