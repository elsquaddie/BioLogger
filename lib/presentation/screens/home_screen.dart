import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/controllers/home_controller.dart';
import '../../domain/controllers/data_entry_controller.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/ui_components/index.dart';
import '../theme/app_theme.dart';
import 'main_navigation_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('BioLogger'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.brandGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Календарный виджет
            Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(() => CalendarWidget(
                selectedDate: controller.selectedDate.value,
                filledDates: controller.filledDates.value,
                onDateSelected: controller.selectDate,
                onMonthChanged: controller.changeMonth,
                displayMonth: controller.currentMonth.value,
              )),
            ),
            
            // Заголовок статистики
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Статистика заполнений',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ),
            
            // Статистика в карточках
            _buildCompactStats(controller, theme),
            
            const SizedBox(height: 24),
            
            // Кнопка добавить запись
            _buildActionButton(context, controller, theme),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Создает компактную статистику в новом дизайне
  Widget _buildCompactStats(HomeController controller, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() => Row(
        children: [
          // Streak (серия дней)
          Expanded(
            child: AppCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  TintedIconBox(
                    icon: Icons.local_fire_department,
                    size: 56,
                    iconSize: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${controller.consecutiveDays.value}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          'Дней подряд',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Monthly count
          Expanded(
            child: AppCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  TintedIconBox(
                    icon: Icons.event,
                    size: 56,
                    iconSize: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${controller.monthlyFilledDays.value}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          'В этом месяце',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      )),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        final isEnabled = controller.isActionButtonEnabled;
        final isFilled = controller.isSelectedDateFilled;
        
        return PrimaryButton(
          text: isFilled ? 'Посмотреть запись' : 'Добавить запись',
          icon: isFilled ? Icons.visibility : Icons.add,
          onPressed: isEnabled ? () => _onActionButtonPressed(context, controller) : null,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
        );
      }),
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
      if (mode == 'edit') {
        // При переходе в режим редактирования с кнопки "Записать данные" начинаем с первого параметра
        dataEntryController.currentParameterIndex.value = 0;
      }
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

