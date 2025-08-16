import '../../../data/repositories/daily_record_repository.dart';
import '../../../models/daily_record.dart';

/// Use case для подсчета серий дней и статистики заполненности календаря
class CalculateStreakUseCase {
  final DailyRecordRepository _dailyRecordRepository;

  CalculateStreakUseCase(this._dailyRecordRepository);

  /// Подсчет дней подряд (текущая серия без пропусков от сегодня назад)
  Future<int> getConsecutiveDays() async {
    try {
      final allRecords = await _dailyRecordRepository.getAllDailyRecords();
      
      if (allRecords.isEmpty) return 0;

      final today = DateTime.now();
      final normalizedToday = DateTime(today.year, today.month, today.day);
      
      int consecutiveDays = 0;
      DateTime currentCheckDate = normalizedToday;

      // Создаем Map для быстрого поиска записей по дате
      final recordsByDate = <DateTime, DailyRecord>{};
      for (final record in allRecords) {
        final recordDate = DateTime(record.date.year, record.date.month, record.date.day);
        recordsByDate[recordDate] = record;
      }

      // Проверяем каждый день начиная с сегодня и идем назад
      while (true) {
        final record = recordsByDate[currentCheckDate];
        
        if (record != null) {
          // Проверяем что запись действительно содержит данные
          if (record.dataValues.isNotEmpty && 
              record.dataValues.values.any((value) => 
                value != null && value.toString().trim().isNotEmpty)) {
            consecutiveDays++;
            // Переходим к предыдущему дню
            currentCheckDate = currentCheckDate.subtract(const Duration(days: 1));
          } else {
            // Запись есть, но пустая - прерываем серию
            break;
          }
        } else {
          // Нет записи за этот день - прерываем серию
          break;
        }
      }

      return consecutiveDays;
    } catch (e) {
      print('Ошибка при подсчете последовательных дней: $e');
      return 0;
    }
  }

  /// Подсчет заполненных дней в конкретном месяце
  Future<int> getFilledDaysInMonth(DateTime month) async {
    try {
      final allRecords = await _dailyRecordRepository.getAllDailyRecords();
      
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0); // Последний день месяца

      int filledDays = 0;

      for (final record in allRecords) {
        final recordDate = DateTime(record.date.year, record.date.month, record.date.day);
        
        // Проверяем что дата в нужном месяце
        if (recordDate.isAtSameMomentAs(startOfMonth) || 
            (recordDate.isAfter(startOfMonth) && recordDate.isBefore(endOfMonth)) ||
            recordDate.isAtSameMomentAs(endOfMonth)) {
          
          // Проверяем что запись содержит данные
          if (record.dataValues.isNotEmpty && 
              record.dataValues.values.any((value) => 
                value != null && value.toString().trim().isNotEmpty)) {
            filledDays++;
          }
        }
      }

      return filledDays;
    } catch (e) {
      print('Ошибка при подсчете заполненных дней в месяце: $e');
      return 0;
    }
  }

  /// Получение списка всех заполненных дат для отображения в календаре
  Future<List<DateTime>> getFilledDates() async {
    try {
      final allRecords = await _dailyRecordRepository.getAllDailyRecords();
      final filledDates = <DateTime>[];

      for (final record in allRecords) {
        // Проверяем что запись содержит данные
        if (record.dataValues.isNotEmpty && 
            record.dataValues.values.any((value) => 
              value != null && value.toString().trim().isNotEmpty)) {
          
          final normalizedDate = DateTime(record.date.year, record.date.month, record.date.day);
          filledDates.add(normalizedDate);
        }
      }

      // Удаляем дубликаты и сортируем
      final uniqueDates = filledDates.toSet().toList();
      uniqueDates.sort();
      
      return uniqueDates;
    } catch (e) {
      print('Ошибка при получении заполненных дат: $e');
      return [];
    }
  }

  /// Получение заполненных дат для конкретного месяца (оптимизированная версия)
  Future<Set<DateTime>> getFilledDatesInMonth(DateTime month) async {
    try {
      final allRecords = await _dailyRecordRepository.getAllDailyRecords();
      final filledDates = <DateTime>{};

      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0);

      for (final record in allRecords) {
        final recordDate = DateTime(record.date.year, record.date.month, record.date.day);
        
        // Проверяем что дата в нужном месяце
        if (recordDate.isAtSameMomentAs(startOfMonth) || 
            (recordDate.isAfter(startOfMonth) && recordDate.isBefore(endOfMonth)) ||
            recordDate.isAtSameMomentAs(endOfMonth)) {
          
          // Проверяем что запись содержит данные
          if (record.dataValues.isNotEmpty && 
              record.dataValues.values.any((value) => 
                value != null && value.toString().trim().isNotEmpty)) {
            filledDates.add(recordDate);
          }
        }
      }

      return filledDates;
    } catch (e) {
      print('Ошибка при получении заполненных дат в месяце: $e');
      return <DateTime>{};
    }
  }

  /// Проверка заполнен ли конкретный день
  Future<bool> isDayFilled(DateTime day) async {
    try {
      final normalizedDay = DateTime(day.year, day.month, day.day);
      final record = await _dailyRecordRepository.getDailyRecordByDate(normalizedDay);
      
      if (record == null) return false;
      
      // Проверяем что запись содержит данные
      return record.dataValues.isNotEmpty && 
             record.dataValues.values.any((value) => 
               value != null && value.toString().trim().isNotEmpty);
    } catch (e) {
      print('Ошибка при проверке заполненности дня: $e');
      return false;
    }
  }

  /// Получение максимальной серии дней за всё время
  Future<int> getMaxStreak() async {
    try {
      final allRecords = await _dailyRecordRepository.getAllDailyRecords();
      
      if (allRecords.isEmpty) return 0;

      // Получаем все заполненные даты
      final filledDates = <DateTime>[];
      for (final record in allRecords) {
        if (record.dataValues.isNotEmpty && 
            record.dataValues.values.any((value) => 
              value != null && value.toString().trim().isNotEmpty)) {
          
          final normalizedDate = DateTime(record.date.year, record.date.month, record.date.day);
          filledDates.add(normalizedDate);
        }
      }

      if (filledDates.isEmpty) return 0;

      // Удаляем дубликаты и сортируем
      final uniqueDates = filledDates.toSet().toList();
      uniqueDates.sort();

      int maxStreak = 1;
      int currentStreak = 1;

      for (int i = 1; i < uniqueDates.length; i++) {
        final previousDate = uniqueDates[i - 1];
        final currentDate = uniqueDates[i];
        
        // Проверяем что даты идут подряд (разница = 1 день)
        if (currentDate.difference(previousDate).inDays == 1) {
          currentStreak++;
          maxStreak = currentStreak > maxStreak ? currentStreak : maxStreak;
        } else {
          currentStreak = 1;
        }
      }

      return maxStreak;
    } catch (e) {
      print('Ошибка при подсчете максимальной серии: $e');
      return 0;
    }
  }
}