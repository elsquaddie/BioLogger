import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../domain/controllers/data_entry_controller.dart';
import '../theme/app_theme.dart';

class DataEntryScreen extends StatefulWidget {
  const DataEntryScreen({Key? key}) : super(key: key);

  @override
  State<DataEntryScreen> createState() => _DataEntryScreenState();
}

class _DataEntryScreenState extends State<DataEntryScreen> {
  final DataEntryController _dataEntryController = Get.find<DataEntryController>();
  late TextEditingController _valueController;
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    // DataEntryScreen initState
    _valueController = TextEditingController();
    _commentController = TextEditingController();

    // Загружаем значения при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTextFieldForParameter();
    });

    // Слушаем изменения индекса
    ever(_dataEntryController.currentParameterIndex, (index) {
      _updateTextFieldForParameter();
    });

    ever(_dataEntryController.selectedDate, (date) {
      _updateTextFieldForParameter();
    });
  }

  Future<void> _updateTextFieldForParameter() async {
    final currentParameter = _dataEntryController.currentParameter;
    if (currentParameter != null) {
      // Use selectedDate from controller instead of DateTime.now()
      final selectedDate = _dataEntryController.selectedDate.value;
      final normalizedDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      
      // Получаем запись для выбранной даты
      final dailyRecord = await _dataEntryController.getDailyRecordByDate(normalizedDate);

      if (mounted) {
        String value = '';
        String comment = '';
        if (dailyRecord != null) {
          value = dailyRecord.dataValues[currentParameter.id.toString()]?.toString() ?? '';
          comment = dailyRecord.comments[currentParameter.id.toString()] ?? '';
          // Found value and comment for parameter
        } else {
          // No record found for date
        }

        setState(() {
          _valueController.text = value;
          _commentController.text = comment;
          // Обновляем значение и комментарий в контроллере
          _dataEntryController.updateEnteredValue(currentParameter.id.toString(), value);
          _dataEntryController.updateEnteredComment(currentParameter.id.toString(), comment);
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _valueController.text = '';
          _commentController.text = '';
        });
      }
    }
  }

  @override
  void dispose() {
    // DataEntryScreen dispose
    _valueController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Ввод данных'),
        elevation: 0,
        actions: [
          // Прогресс индикатор
          Obx(() {
            final totalParams = _dataEntryController.parametersForEntry.length;
            final currentIndex = _dataEntryController.currentParameterIndex.value;
            if (totalParams == 0) return const SizedBox.shrink();
            
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '${currentIndex + 1} / $totalParams',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        final currentParameter = _dataEntryController.currentParameter;

        if (currentParameter == null) {
          return Center(
            child: Card(
              margin: AppTheme.pagePadding,
              child: Padding(
                padding: AppTheme.cardPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Все параметры заполнены!',
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Данные сохранены успешно',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            // Прогресс бар
            SliverToBoxAdapter(
              child: Container(
                margin: AppTheme.pagePadding,
                child: Column(
                  children: [
                    Obx(() {
                      final totalParams = _dataEntryController.parametersForEntry.length;
                      final currentIndex = _dataEntryController.currentParameterIndex.value;
                      final progress = totalParams > 0 ? (currentIndex + 1) / totalParams : 0.0;
                      
                      return LinearProgressIndicator(
                        value: progress,
                        backgroundColor: theme.colorScheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                        minHeight: 6,
                      );
                    }),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            
            // Выбор даты
            SliverToBoxAdapter(
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: AppTheme.cardPadding,
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Дата:',
                        style: theme.textTheme.titleMedium,
                      ),
                      const Spacer(),
                      Obx(() => TextButton.icon(
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _dataEntryController.selectedDate.value,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            _dataEntryController.selectDate(pickedDate);
                          }
                        },
                        icon: const Icon(Icons.edit),
                        label: Text(
                          DateFormat('dd.MM.yyyy').format(_dataEntryController.selectedDate.value),
                          style: theme.textTheme.labelLarge,
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ),
            
            // Основная карточка с параметром
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: AppTheme.pagePadding,
                child: Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: AppTheme.cardPadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Заголовок параметра
                            Text(
                              currentParameter.name,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (currentParameter.unit != null && currentParameter.unit!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Единицы измерения: ${currentParameter.unit}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            
                            // Поле ввода значения
                            TextFormField(
                              key: ValueKey(currentParameter.id),
                              controller: _valueController,
                              decoration: InputDecoration(
                                labelText: 'Введите значение',
                                hintText: currentParameter.unit != null 
                                    ? 'Например: 10 ${currentParameter.unit}'
                                    : 'Введите значение',
                                prefixIcon: Icon(
                                  _getParameterIcon(currentParameter.dataType),
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              keyboardType: _getKeyboardType(currentParameter.dataType),
                              onChanged: (value) {
                                _dataEntryController.updateEnteredValue(currentParameter.id.toString(), value);
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Поле комментария
                            TextFormField(
                              key: ValueKey('comment_${currentParameter.id}'),
                              controller: _commentController,
                              decoration: const InputDecoration(
                                labelText: 'Комментарий',
                                hintText: 'Добавьте заметку (необязательно)',
                                prefixIcon: Icon(Icons.comment_outlined),
                              ),
                              maxLines: 3,
                              minLines: 1,
                              onChanged: (value) {
                                _dataEntryController.updateEnteredComment(currentParameter.id.toString(), value);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Кнопки навигации
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _dataEntryController.currentParameterIndex.value > 0
                                  ? () => _dataEntryController.previousParameter()
                                  : null,
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Назад'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Obx(() => ElevatedButton.icon(
                              onPressed: () => _dataEntryController.nextParameter(),
                              icon: Icon(_dataEntryController.isLastParameter 
                                  ? Icons.save 
                                  : Icons.arrow_forward),
                              label: Text(_dataEntryController.isLastParameter 
                                  ? 'Сохранить' 
                                  : 'Далее'),
                            )),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _dataEntryController.saveDailyRecord(),
        icon: const Icon(Icons.save),
        label: const Text('Сохранить все'),
      ),
    );
  }
  
  IconData _getParameterIcon(String dataType) {
    switch (dataType.toLowerCase()) {
      case 'number':
        return Icons.numbers;
      case 'text':
        return Icons.text_fields;
      case 'rating':
        return Icons.star_rate;
      case 'yes/no':
      case 'yesno':
        return Icons.check_box;
      case 'time':
        return Icons.access_time;
      case 'date':
        return Icons.date_range;
      default:
        return Icons.edit;
    }
  }
  
  TextInputType _getKeyboardType(String dataType) {
    switch (dataType.toLowerCase()) {
      case 'number':
      case 'rating':
        return TextInputType.number;
      case 'text':
        return TextInputType.text;
      default:
        return TextInputType.text;
    }
  }
}