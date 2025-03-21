import '../../models/daily_record.dart';
import '../../data/repositories/daily_record_repository.dart';
import '../../data/repositories/daily_record_repository_impl.dart';

class GetAllDailyRecordsUseCase {
  final DailyRecordRepository _dailyRecordRepository = DailyRecordRepositoryImpl();

  Future<List<DailyRecord>> execute() async {
    return await _dailyRecordRepository.getAllDailyRecords();
  }
}
