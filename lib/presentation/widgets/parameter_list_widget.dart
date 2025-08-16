import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/controllers/parameter_controller.dart';
import '../../models/parameter.dart';
import '../screens/parameter_create_screen.dart';
import '../screens/parameter_edit_screen.dart';
import '../theme/app_theme.dart';
import '../animations/page_transitions.dart';
import '../widgets/ui_components/index.dart';
import '../../utils/parameter_icons.dart';

class ParameterListWidget extends StatelessWidget {
  ParameterListWidget({Key? key}) : super(key: key);

  final ParameterController _parameterController = Get.find();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Obx(() {
        if (!_parameterController.isParametersLoaded.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Загрузка параметров...',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          );
        } else if (_parameterController.parameters.isEmpty) {
          return Center(
            child: Padding(
              padding: AppTheme.pagePadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.tune,
                    size: 80,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Пока нет параметров',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Создайте первый параметр для отслеживания ваших данных',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pushWithTransition(
                      const ParameterCreateScreen(),
                      transition: PageTransitionType.slideFromBottom,
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Создать первый параметр'),
                  ),
                ],
              ),
            ),
          );
        } else {
          // Единый список всех параметров
          return Column(
            children: [
              // Кнопка добавления параметра в виде элемента списка
              InkWell(
                onTap: () => Navigator.of(context).pushWithTransition(
                  const ParameterCreateScreen(),
                  transition: PageTransitionType.slideFromBottom,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.tintGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.add,
                          color: AppTheme.brandGreen,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Добавить параметр',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppTheme.brandGreen,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Основной список параметров
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.all(0),
                  itemCount: _parameterController.parameters.length,
                  onReorder: (oldIndex, newIndex) async {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    
                    final reorderedParams = List<Parameter>.from(_parameterController.parameters);
                    final parameter = reorderedParams.removeAt(oldIndex);
                    reorderedParams.insert(newIndex, parameter);
                    
                    // Обновляем sort_order для всех параметров
                    await _parameterController.reorderAllParameters(reorderedParams);
                  },
                  itemBuilder: (context, index) {
                    // CRITICAL FIX: Get parameter by ID from controller to avoid reordering issues
                    final parameter = _parameterController.parameters[index];
                    
                    // DEBUG: Log parameter being built at index
                    print("ReorderableListView: Building tile at index $index for parameter '${parameter.name}' with ID ${parameter.id}");
                    
                    return _buildParameterTile(context, parameter, theme, index);
                  },
                ),
              ),
            ],
          );
        }
      });
  }

  // Единый виджет для всех параметров
  Widget _buildParameterTile(BuildContext context, Parameter parameter, ThemeData theme, int index) {
    // Создаем строку с типом и единицей измерения
    String typeAndUnit = parameter.dataType;
    if (parameter.unit != null && parameter.unit!.isNotEmpty) {
      typeAndUnit += ' • ${parameter.unit}';
    }
    
    // CRITICAL FIX: Capture parameter ID to avoid closure issues
    final parameterToEdit = parameter; // Explicit local copy
    final parameterId = parameter.id;
    
    return Container(
      key: ValueKey(parameter.id),
      child: InkWell(
        onTap: () {
          // CRITICAL FIX: Find parameter by ID to ensure we get the correct one
          final currentParameter = _parameterController.parameters.firstWhere(
            (p) => p.id == parameterId,
            orElse: () => parameterToEdit, // fallback
          );
          
          // DEBUG: Log which parameter is being tapped
          print("Navigation Debug: Tapping parameter '${currentParameter.name}' with ID: ${currentParameter.id}");
          
          Navigator.of(context).pushWithTransition(
            ParameterEditScreen(parameter: currentParameter),
            transition: PageTransitionType.slideAndFade,
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Drag handle
              ReorderableDragStartListener(
                index: index,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.drag_handle,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Иконка параметра с кастомными цветами
              SmallTintedIconBox(
                icon: ParameterIcons.getIcon(parameter),
                size: 48,
                iconSize: 24,
                backgroundColor: ParameterIcons.getIconBackgroundColor(parameter, theme.colorScheme),
                iconColor: ParameterIcons.getIconColor(parameter, theme.colorScheme),
              ),
              const SizedBox(width: 16),
              // Название и тип данных
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      parameter.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1F2937),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      typeAndUnit,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Переключатель активности
              Switch(
                value: parameterToEdit.isEnabled,
                onChanged: (value) async {
                  // DEBUG: Log switch toggle
                  print("Navigation Debug: Toggle switch for parameter '${parameterToEdit.name}' with ID: $parameterId");
                  
                  await _parameterController.toggleParameterEnabled(parameterId!, value);
                },
              ),
              const SizedBox(width: 8),
              
              // Меню действий
              PopupMenuButton<String>(
                onSelected: (value) {
                  // CRITICAL FIX: Find parameter by ID for popup actions too
                  final currentParameter = _parameterController.parameters.firstWhere(
                    (p) => p.id == parameterId,
                    orElse: () => parameterToEdit, // fallback
                  );
                  
                  if (value == 'edit') {
                    // DEBUG: Log popup menu edit action
                    print("Navigation Debug: Popup edit for parameter '${currentParameter.name}' with ID: ${currentParameter.id}");
                    
                    Navigator.of(context).pushWithTransition(
                      ParameterEditScreen(parameter: currentParameter),
                      transition: PageTransitionType.slideAndFade,
                    );
                  } else if (value == 'delete') {
                    _showDeleteConfirmationDialog(context, currentParameter);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        const Text('Редактировать'),
                      ],
                    ),
                  ),
                  if (!parameter.isPreset) // Только для пользовательских параметров
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: theme.colorScheme.error),
                          const SizedBox(width: 12),
                          const Text('Удалить'),
                        ],
                      ),
                    ),
                ],
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.more_vert,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Parameter parameter) {
    final theme = Theme.of(context);
    
    // Проверяем, что это не пресет параметр
    if (parameter.isPreset) {
      Get.snackbar(
        'Невозможно удалить',
        'Встроенные параметры нельзя удалить. Вы можете их отключить.',
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
        borderRadius: 12,
        duration: const Duration(seconds: 4),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Icon(
            Icons.warning_amber_rounded,
            color: theme.colorScheme.error,
            size: 32,
          ),
          title: const Text('Удалить параметр?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Вы уверены, что хотите удалить параметр "${parameter.name}"?',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Все связанные данные будут потеряны навсегда. Это действие нельзя отменить.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                
                // Показываем индикатор загрузки
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
                
                try {
                  await _parameterController.deleteParameter(parameter.id!);
                  Navigator.of(context).pop(); // Закрыть loading
                  
                  Get.snackbar(
                    'Успех',
                    'Параметр "${parameter.name}" удален',
                    snackPosition: SnackPosition.TOP,
                    margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
                    backgroundColor: Get.theme.colorScheme.primaryContainer,
                    colorText: Get.theme.colorScheme.onPrimaryContainer,
                    borderRadius: 12,
                    duration: const Duration(seconds: 3),
                  );
                } catch (e) {
                  Navigator.of(context).pop(); // Закрыть loading
                  
                  Get.snackbar(
                    'Ошибка',
                    'Ошибка удаления: ${e.toString()}',
                    snackPosition: SnackPosition.TOP,
                    margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
                    backgroundColor: Get.theme.colorScheme.errorContainer,
                    colorText: Get.theme.colorScheme.onErrorContainer,
                    borderRadius: 12,
                    duration: const Duration(seconds: 4),
                  );
                }
              },
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );
  }
}