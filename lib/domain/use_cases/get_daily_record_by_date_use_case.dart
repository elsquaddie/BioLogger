import '../../models/daily_record.dart';
import '../../data/repositories/daily_record_repository.dart';
import '../../data/repositories/daily_record_repository_impl.dart';

class GetDailyRecordByDateUseCase {
  final DailyRecordRepository _dailyRecordRepository = DailyRecordRepositoryImpl();

  Future<DailyRecord?> execute(DateTime date) async {
    return await _dailyRecordRepository.getDailyRecordByDate(date);
  }
}
