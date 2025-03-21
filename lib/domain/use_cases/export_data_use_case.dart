// lib/domain/use_cases/export_data_use_case.dart

import '../../data/repositories/daily_record_repository.dart';
import '../../data/repositories/parameter_repository.dart';
import '../../models/daily_record.dart';
import '../../models/parameter.dart';

class ExportDataUseCase {
  final DailyRecordRepository _dailyRecordRepository;
  final ParameterRepository _parameterRepository; // Добавьте репозиторий параметров

  ExportDataUseCase(this._dailyRecordRepository, this._parameterRepository);

  Future<(List<Parameter>, List<DailyRecord>)> execute() async {
    final parameters = await _parameterRepository.getAllParameters(); // Получите все параметры
    final dailyRecords = await _dailyRecordRepository.getAllDailyRecords(); // Получите все записи
    return (parameters, dailyRecords);
  }
}