import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/controllers/parameter_controller.dart';
import '../../models/parameter.dart';
import 'parameter_create_screen.dart';
import 'parameter_edit_screen.dart';
import '../theme/app_theme.dart';
import '../animations/page_transitions.dart';

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
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _parameterController.parameters.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final parameter = _parameterController.parameters[index];
              return Card(
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
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getParameterIcon(parameter.dataType),
                            color: theme.colorScheme.onPrimaryContainer,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                parameter.name,
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Row(
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
                                  if (parameter.unit != null && parameter.unit!.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      parameter.unit!,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
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
                  ),
                ),
              );
            },
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

  IconData _getParameterIcon(String dataType) {
    switch (dataType.toLowerCase()) {
      case 'число':
      case 'number':
        return Icons.numbers;
      case 'текст':
      case 'text':
        return Icons.text_fields;
      case 'оценка':
      case 'rating':
        return Icons.star_rate;
      case 'да/нет':
      case 'yes/no':
      case 'yesno':
        return Icons.check_box;
      case 'время':
      case 'time':
        return Icons.access_time;
      case 'дата':
      case 'date':
        return Icons.date_range;
      default:
        return Icons.tune;
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, Parameter parameter) {
    final theme = Theme.of(context);
    
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