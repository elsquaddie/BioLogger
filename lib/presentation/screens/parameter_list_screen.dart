import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/controllers/parameter_controller.dart';
import '../../models/parameter.dart';
import 'parameter_create_screen.dart';
import 'parameter_edit_screen.dart';
import '../theme/app_theme.dart';
import '../animations/page_transitions.dart';
import '../../utils/parameter_icons.dart';

class ParameterListScreen extends StatelessWidget {
  ParameterListScreen({Key? key}) : super(key: key);

  final ParameterController _parameterController = Get.find();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Управление параметрами'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Создать параметр',
            onPressed: () => Navigator.of(context).pushWithTransition(
              const ParameterCreateScreen(),
              transition: PageTransitionType.slideFromBottom,
            ),
          ),
        ],
      ),
      body: Obx(() {
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
          return Padding(
            padding: const EdgeInsets.only(bottom: 80), // Отступ для FAB
            child: ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
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
                final parameter = _parameterController.parameters[index];
                return _buildParameterTile(context, parameter, theme, index);
              },
            ),
          );
        }
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushWithTransition(
          const ParameterCreateScreen(),
          transition: PageTransitionType.slideFromBottom,
        ),
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
    );
  }

  // Единый виджет для всех параметров
  Widget _buildParameterTile(BuildContext context, Parameter parameter, ThemeData theme, int index) {
    return Card(
      key: ValueKey(parameter.id),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () => Navigator.of(context).pushWithTransition(
          ParameterEditScreen(parameter: parameter),
          transition: PageTransitionType.slideAndFade,
        ),
        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
        child: Padding(
          padding: AppTheme.cardPadding,
          child: Row(
            children: [
              // Drag handle + Иконка
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.drag_handle,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  ParameterIcons.buildParameterIcon(
                    parameter,
                    context,
                    size: 24.0,
                    padding: 12.0,
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Основная информация
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      parameter.name,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Chip(
                          label: Text(
                            parameter.dataType,
                            style: theme.textTheme.bodySmall,
                          ),
                          backgroundColor: theme.colorScheme.secondaryContainer,
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        if (parameter.isPreset)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 12,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Пресет',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (parameter.unit != null && parameter.unit!.isNotEmpty)
                          Chip(
                            label: Text(
                              parameter.unit!,
                              style: theme.textTheme.bodySmall,
                            ),
                            backgroundColor: theme.colorScheme.surfaceVariant,
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Кнопки управления
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Переключатель активности
                  Switch(
                    value: parameter.isEnabled,
                    onChanged: (value) async {
                      await _parameterController.toggleParameterEnabled(parameter.id!, value);
                    },
                  ),
                  const SizedBox(width: 8),
                  // Меню действий
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.of(context).pushWithTransition(
                          ParameterEditScreen(parameter: parameter),
                          transition: PageTransitionType.slideAndFade,
                        );
                      } else if (value == 'delete') {
                        _showDeleteConfirmationDialog(context, parameter);
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
                  ),
                ],
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Встроенные параметры нельзя удалить. Вы можете их отключить.'),
          backgroundColor: theme.colorScheme.errorContainer,
          behavior: SnackBarBehavior.floating,
        ),
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
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Параметр "${parameter.name}" удален'),
                      backgroundColor: theme.colorScheme.primaryContainer,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } catch (e) {
                  Navigator.of(context).pop(); // Закрыть loading
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ошибка удаления: ${e.toString()}'),
                      backgroundColor: theme.colorScheme.error,
                      behavior: SnackBarBehavior.floating,
                    ),
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