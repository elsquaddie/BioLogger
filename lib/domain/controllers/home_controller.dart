import 'package:get/get.dart';
import '../use_cases/calculate_streak_use_case.dart';

/// Контроллер для главного экрана с календарной логикой
class HomeController extends GetxController {
  final CalculateStreakUseCase _calculateStreakUseCase;

  HomeController(this._calculateStreakUseCase);

  // Reactive переменные
  var selectedDate = DateTime.now().obs;
  var currentMonth = DateTime.now().obs;
  var filledDates = <DateTime>{}.obs;
  var consecutiveDays = 0.obs;
  var monthlyFilledDays = 0.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  /// Инициализация данных при запуске контроллера
  Future<void> _initializeData() async {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    
    selectedDate.value = normalizedToday;
    currentMonth.value = DateTime(today.year, today.month, 1);
    
    await loadFilledDays();
    await updateCounters();
  }

  /// Загрузка всех заполненных дат из базы данных
  Future<void> loadFilledDays() async {
    try {
      isLoading.value = true;
      
      final dates = await _calculateStreakUseCase.getFilledDates();
      filledDates.value = dates.toSet();
      
      // Также загружаем данные для текущего месяца для оптимизации
      await _loadFilledDatesForCurrentMonth();
      
    } catch (e) {
      print('Ошибка загрузки заполненных дат: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Загрузка заполненных дат только для текущего отображаемого месяца
  Future<void> _loadFilledDatesForCurrentMonth() async {
    try {
      final monthDates = await _calculateStreakUseCase
          .getFilledDatesInMonth(currentMonth.value);
      
      // Обновляем основной set, добавляя данные текущего месяца
      final updatedDates = Set<DateTime>.from(filledDates.value);
      updatedDates.addAll(monthDates);
      filledDates.value = updatedDates;
      
    } catch (e) {
      print('Ошибка загрузки дат для месяца: $e');
    }
  }

  /// Обновление счетчиков (дни подряд и дни в месяце)
  Future<void> updateCounters() async {
    try {
      isLoading.value = true;

      // Подсчет текущей серии дней подряд
      final consecutive = await _calculateStreakUseCase.getConsecutiveDays();
      consecutiveDays.value = consecutive;

      // Подсчет заполненных дней в текущем месяце
      final monthlyFilled = await _calculateStreakUseCase
          .getFilledDaysInMonth(currentMonth.value);
      monthlyFilledDays.value = monthlyFilled;

    } catch (e) {
      print('Ошибка обновления счетчиков: $e');
      // Устанавливаем значения по умолчанию в случае ошибки
      consecutiveDays.value = 0;
      monthlyFilledDays.value = 0;
    } finally {
      isLoading.value = false;
    }
  }

  /// Выбор даты пользователем
  void selectDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    selectedDate.value = normalizedDate;

    // Если выбрана дата из другого месяца, переключаем месяц
    final selectedMonth = DateTime(date.year, date.month, 1);
    if (selectedMonth != currentMonth.value) {
      changeMonth(selectedMonth);
    }
  }

  /// Изменение отображаемого месяца
  void changeMonth(DateTime month) async {
    final normalizedMonth = DateTime(month.year, month.month, 1);
    currentMonth.value = normalizedMonth;

    // Перезагружаем данные для нового месяца
    await _loadFilledDatesForCurrentMonth();
    await updateCounters();
  }

  /// Переход к предыдущему месяцу
  void previousMonth() {
    final prevMonth = DateTime(
      currentMonth.value.year,
      currentMonth.value.month - 1,
      1,
    );
    changeMonth(prevMonth);
  }

  /// Переход к следующему месяцу
  void nextMonth() {
    final nextMonth = DateTime(
      currentMonth.value.year,
      currentMonth.value.month + 1,
      1,
    );
    changeMonth(nextMonth);
  }

  /// Проверка, заполнен ли конкретный день
  bool isDateFilled(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return filledDates.contains(normalizedDate);
  }

  /// Проверка, является ли выбранный день заполненным
  bool get isSelectedDateFilled {
    return isDateFilled(selectedDate.value);
  }

  /// Проверка, является ли выбранный день сегодняшним
  bool get isSelectedDateToday {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedSelected = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
    );
    return normalizedSelected == normalizedToday;
  }

  /// Проверка, является ли выбранный день будущим
  bool get isSelectedDateInFuture {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedSelected = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
    );
    return normalizedSelected.isAfter(normalizedToday);
  }

  /// Получение текста для динамической кнопки
  String get actionButtonText {
    if (isSelectedDateInFuture) {
      return 'Будущий день';
    } else if (isSelectedDateFilled) {
      return 'Посмотреть данные';
    } else {
      return 'Ввести данные';
    }
  }

  /// Проверка, доступна ли кнопка действия
  bool get isActionButtonEnabled {
    return !isSelectedDateInFuture;
  }

  /// Получение названия текущего месяца для отображения
  String get currentMonthName {
    final months = [
      'январе', 'феврале', 'марте', 'апреле', 'мае', 'июне',
      'июле', 'августе', 'сентябре', 'октябре', 'ноябре', 'декабре'
    ];
    return months[currentMonth.value.month - 1];
  }

  /// Принудительное обновление всех данных
  Future<void> refreshData() async {
    await loadFilledDays();
    await updateCounters();
  }

  /// Обновление данных после добавления новой записи
  Future<void> onDataEntryCompleted() async {
    // Перезагружаем данные после того как пользователь ввел данные
    await refreshData();
  }

  /// Получение максимальной серии за все время (опционально)
  Future<int> getMaxStreak() async {
    try {
      return await _calculateStreakUseCase.getMaxStreak();
    } catch (e) {
      print('Ошибка получения максимальной серии: $e');
      return 0;
    }
  }

  /// Отладочная информация
  void printDebugInfo() {
    print('=== HomeController Debug Info ===');
    print('Selected Date: ${selectedDate.value}');
    print('Current Month: ${currentMonth.value}');
    print('Filled Dates Count: ${filledDates.length}');
    print('Consecutive Days: ${consecutiveDays.value}');
    print('Monthly Filled Days: ${monthlyFilledDays.value}');
    print('Is Selected Date Filled: $isSelectedDateFilled');
    print('Action Button Text: $actionButtonText');
    print('=====================================');
  }
}