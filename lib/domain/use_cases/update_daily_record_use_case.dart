import '../../models/daily_record.dart';
import '../../data/repositories/daily_record_repository.dart';
import '../../data/repositories/daily_record_repository_impl.dart';

class UpdateDailyRecordUseCase {
  final DailyRecordRepository _dailyRecordRepository = DailyRecordRepositoryImpl();

  Future<int> execute(DailyRecord dailyRecord) async {
    return await _dailyRecordRepository.updateDailyRecord(dailyRecord);
  }
}
