import '../../data/repositories/daily_record_repository.dart';
import '../../data/repositories/daily_record_repository_impl.dart';

class DeleteDailyRecordUseCase {
  final DailyRecordRepository _dailyRecordRepository = DailyRecordRepositoryImpl();

  Future<int> execute(int recordId) async {
    return await _dailyRecordRepository.deleteDailyRecord(recordId);
  }
}
