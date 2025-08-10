import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/controllers/home_controller.dart';
import '../../domain/controllers/data_entry_controller.dart';
import '../widgets/calendar_widget.dart';
import 'main_navigation_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('BioLogger'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Календарный виджет (без скроллинга)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Календарный виджет
                  Expanded(
                    child: Obx(() => CalendarWidget(
                      selectedDate: controller.selectedDate.value,
                      filledDates: controller.filledDates.value,
                      onDateSelected: controller.selectDate,
                      onMonthChanged: controller.changeMonth,
                      displayMonth: controller.currentMonth.value,
                    )),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Компактная статистика дней подряд
                  _buildCompactStats(controller, theme),
                ],
              ),
            ),
          ),
          
          // Динамическая кнопка внизу
          _buildActionButton(context, controller, theme),
        ],
      ),
    );
  }

  /// Создает компактную статистику дней подряд
  Widget _buildCompactStats(HomeController controller, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Заголовок
          Text(
            'Серии заполнений:',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),
          
          // Счетчики
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Дни подряд
              Column(
                children: [
                  Text(
                    '${controller.consecutiveDays.value}',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF87A96B), // Sage green
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Дней подряд',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              
              // Дни в месяце
              Column(
                children: [
                  Text(
                    '${controller.monthlyFilledDays.value}',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF87A96B), // Sage green
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Дней в этом месяце',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          )),
        ],
      ),
    );
  }

  /// Создает информацию о выбранной дате
  Widget _buildSelectedDateInfo(HomeController controller, ThemeData theme) {
    return Obx(() {
      final selectedDate = controller.selectedDate.value;
      final isToday = controller.isSelectedDateToday;
      final isFilled = controller.isSelectedDateFilled;
      final isInFuture = controller.isSelectedDateInFuture;
      
      String statusText;
      Color statusColor;
      IconData statusIcon;
      
      if (isInFuture) {
        statusText = 'Будущий день';
        statusColor = theme.colorScheme.onSurface.withOpacity(0.6);
        statusIcon = Icons.schedule;
      } else if (isFilled) {
        statusText = 'День заполнен';
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
      } else {
        statusText = 'Данные не введены';
        statusColor = theme.colorScheme.error;
        statusIcon = Icons.radio_button_unchecked;
      }
      
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Выбранный день',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              
              // Дата
              Text(
                _formatDate(selectedDate),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              
              if (isToday) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Сегодня',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Статус дня
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    statusIcon,
                    color: statusColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    statusText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  /// Создает динамическую кнопку действия
  Widget _buildActionButton(BuildContext context, HomeController controller, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Obx(() {
          final isEnabled = controller.isActionButtonEnabled;
          final buttonText = controller.actionButtonText;
          final isFilled = controller.isSelectedDateFilled;
          
          return ElevatedButton.icon(
            onPressed: isEnabled ? () => _onActionButtonPressed(context, controller) : null,
            icon: Icon(
              isFilled ? Icons.visibility : Icons.add_circle_outline,
              size: 20,
            ),
            label: Text(
              isFilled ? 'Посмотреть данные' : 'Записать данные',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: isEnabled 
                  ? (isFilled ? theme.colorScheme.secondary : theme.colorScheme.primary)
                  : theme.colorScheme.onSurface.withOpacity(0.3),
              foregroundColor: isEnabled 
                  ? (isFilled ? theme.colorScheme.onSecondary : theme.colorScheme.onPrimary)
                  : theme.colorScheme.onSurface.withOpacity(0.6),
              disabledBackgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
              disabledForegroundColor: theme.colorScheme.onSurface.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Обработка нажатия на кнопку действия
  void _onActionButtonPressed(BuildContext context, HomeController controller) {
    try {
      // Определяем режим на основе состояния дня
      final isFilled = controller.isSelectedDateFilled;
      final mode = isFilled ? 'list' : 'edit'; // Если заполнено - показываем список, иначе сразу редактирование
      
      // Устанавливаем режим в DataEntryController
      final dataEntryController = Get.find<DataEntryController>();
      dataEntryController.setInitialViewMode(mode);
      
      // Переключаемся на вкладку "Ввод" через NavigationController
      final navigationController = Get.find<NavigationController>();
      navigationController.goToDataEntry();
    } catch (e) {
      print('NavigationController не найден: $e');
    }
  }

  /// Форматирует дату для отображения
  String _formatDate(DateTime date) {
    const months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

