import '../../models/daily_record.dart';
import '../../data/repositories/daily_record_repository.dart';
import '../../data/repositories/daily_record_repository_impl.dart';

class GetDailyRecordUseCase {
  final DailyRecordRepository _dailyRecordRepository = DailyRecordRepositoryImpl();

  Future<DailyRecord?> execute(int recordId) async {
    return await _dailyRecordRepository.getDailyRecord(recordId);
  }
}
