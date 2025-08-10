import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Переиспользуемый календарный виджет для отображения и выбора дат
class CalendarWidget extends StatefulWidget {
  /// Выбранная в данный момент дата
  final DateTime selectedDate;
  
  /// Список заполненных дат (с данными)
  final Set<DateTime> filledDates;
  
  /// Колбэк при выборе даты
  final Function(DateTime) onDateSelected;
  
  /// Колбэк при изменении месяца
  final Function(DateTime) onMonthChanged;
  
  /// Отображаемый месяц (если не указан, используется selectedDate)
  final DateTime? displayMonth;

  const CalendarWidget({
    super.key,
    required this.selectedDate,
    required this.filledDates,
    required this.onDateSelected,
    required this.onMonthChanged,
    this.displayMonth,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.displayMonth ?? 
        DateTime(widget.selectedDate.year, widget.selectedDate.month, 1);
  }

  @override
  void didUpdateWidget(CalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.displayMonth != null && widget.displayMonth != oldWidget.displayMonth) {
      _currentMonth = widget.displayMonth!;
    }
  }

  /// Переход к предыдущему месяцу
  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
    widget.onMonthChanged(_currentMonth);
  }

  /// Переход к следующему месяцу
  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
    widget.onMonthChanged(_currentMonth);
  }

  /// Генерация всех дней для отображения в календаре (42 дня = 6 недель)
  List<DateTime> _generateCalendarDays() {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    
    // Определяем первый день недели (понедельник = 1, воскресенье = 7)
    final firstWeekday = firstDayOfMonth.weekday;
    final startDate = firstDayOfMonth.subtract(Duration(days: firstWeekday - 1));
    
    final days = <DateTime>[];
    for (int i = 0; i < 42; i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    
    return days;
  }

  /// Проверяет, является ли день заполненным
  bool _isDayFilled(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return widget.filledDates.contains(normalizedDay);
  }

  /// Проверяет, является ли день выбранным
  bool _isDaySelected(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final normalizedSelected = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    );
    return normalizedDay == normalizedSelected;
  }

  /// Проверяет, принадлежит ли день текущему месяцу
  bool _isDayInCurrentMonth(DateTime day) {
    return day.month == _currentMonth.month && day.year == _currentMonth.year;
  }

  /// Проверяет, является ли день будущим (недоступным для выбора)
  bool _isDayInFuture(DateTime day) {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return normalizedDay.isAfter(normalizedToday);
  }

  /// Обработка клика по дню
  void _onDayTap(DateTime day) {
    if (_isDayInFuture(day)) return; // Будущие дни недоступны
    
    widget.onDateSelected(day);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          children: [
            // Header с навигацией
            _buildHeader(theme),
            const SizedBox(height: 16),
            
            // Заголовки дней недели
            _buildWeekdayHeaders(theme, isSmallScreen),
            const SizedBox(height: 8),
            
            // Сетка календаря
            _buildCalendarGrid(theme, isSmallScreen),
          ],
        ),
      ),
    );
  }

  /// Создает заголовок календаря с навигацией
  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        IconButton(
          onPressed: _previousMonth,
          icon: const Icon(Icons.chevron_left),
          tooltip: 'Предыдущий месяц',
        ),
        Expanded(
          child: Text(
            DateFormat('MMMM yyyy').format(_currentMonth),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          onPressed: _nextMonth,
          icon: const Icon(Icons.chevron_right),
          tooltip: 'Следующий месяц',
        ),
      ],
    );
  }

  /// Создает заголовки дней недели
  Widget _buildWeekdayHeaders(ThemeData theme, bool isSmallScreen) {
    const weekdays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    
    return Row(
      children: weekdays.map((weekday) {
        return Expanded(
          child: Center(
            child: Text(
              weekday,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Создает сетку календаря
  Widget _buildCalendarGrid(ThemeData theme, bool isSmallScreen) {
    final days = _generateCalendarDays();
    final daySize = isSmallScreen ? 36.0 : 44.0;
    
    return Column(
      children: List.generate(6, (weekIndex) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: List.generate(7, (dayIndex) {
              final day = days[weekIndex * 7 + dayIndex];
              return Expanded(
                child: _buildDayCell(day, theme, daySize, isSmallScreen),
              );
            }),
          ),
        );
      }),
    );
  }

  /// Создает ячейку дня
  Widget _buildDayCell(DateTime day, ThemeData theme, double size, bool isSmallScreen) {
    final isSelected = _isDaySelected(day);
    final isFilled = _isDayFilled(day);
    final isInCurrentMonth = _isDayInCurrentMonth(day);
    final isInFuture = _isDayInFuture(day);
    final isToday = _isToday(day);
    
    // Новые визуальные состояния согласно требованиям
    Color backgroundColor = Colors.transparent;
    Color textColor = theme.colorScheme.onSurface;
    Color? borderColor;
    double borderWidth = 0;
    
    if (isInFuture) {
      // Будущие дни - серые, недоступны
      textColor = Colors.grey.shade400;
    } else if (!isInCurrentMonth) {
      // Дни соседних месяцев
      textColor = Colors.grey.shade300;
    } else {
      // Дни текущего месяца
      if (isFilled) {
        if (isSelected) {
          // Выбранная заполненная: зеленый кружок + дополнительная обводка (2px solid)
          backgroundColor = const Color(0xFF87A96B); // Sage green
          textColor = Colors.white;
          borderColor = theme.colorScheme.primary;
          borderWidth = 2;
        } else {
          // Заполненные дни: цифра ВНУТРИ зеленого кружка с заливкой
          backgroundColor = const Color(0xFF87A96B); // Sage green
          textColor = Colors.white;
        }
      } else {
        if (isSelected) {
          // Выбранная незаполненная: серый кружок вокруг цифры
          backgroundColor = Colors.grey.shade300;
          textColor = theme.colorScheme.onSurface;
        } else {
          // Незаполненные доступные: просто цифра без индикации
          backgroundColor = Colors.transparent;
          textColor = theme.colorScheme.onSurface;
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.all(2),
      child: InkWell(
        onTap: isInFuture ? null : () => _onDayTap(day),
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(size / 2),
            border: borderWidth > 0 
                ? Border.all(color: borderColor!, width: borderWidth)
                : null,
          ),
          child: Center(
            child: Text(
              day.day.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Проверяет, является ли день сегодняшним
  bool _isToday(DateTime day) {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return normalizedDay == normalizedToday;
  }
}