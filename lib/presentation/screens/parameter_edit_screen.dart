// lib/presentation/screens/parameter_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/parameter.dart';
import '../../domain/controllers/parameter_controller.dart';
import '../theme/app_theme.dart';

class ParameterEditScreen extends StatefulWidget {
  final Parameter parameter; // Принимаем параметр для редактирования

  const ParameterEditScreen({Key? key, required this.parameter}) : super(key: key);

  @override
  State<ParameterEditScreen> createState() => _ParameterEditScreenState();
}

class _ParameterEditScreenState extends State<ParameterEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _parameterController = Get.find<ParameterController>();

  // Используем TextEditingController для предзаполнения полей
  late TextEditingController _nameController;
  late TextEditingController _unitController;
  String? _dataType; // Тип данных как и раньше

  @override
  void initState() {
    super.initState();
    // Инициализируем контроллеры и тип данных значениями из widget.parameter
    _nameController = TextEditingController(text: widget.parameter.name);
    _unitController = TextEditingController(text: widget.parameter.unit ?? '');
    _dataType = widget.parameter.dataType;
  }

  @override
  void dispose() {
    // Не забываем очищать контроллеры
    _nameController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Редактировать параметр'),
      ),
      body: SingleChildScrollView(
        padding: AppTheme.pagePadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Card(
                child: Padding(
                  padding: AppTheme.cardPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.edit,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Редактирование параметра',
                            style: theme.textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Название параметра',
                          hintText: 'Например: Вес, Настроение, Сон',
                          prefixIcon: const Icon(Icons.label_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Пожалуйста, введите название параметра';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Тип данных',
                          hintText: 'Выберите тип данных для параметра',
                          prefixIcon: const Icon(Icons.category_outlined),
                        ),
                        value: _dataType,
                        items: <String>['Число', 'Текст', 'Оценка', 'Да/Нет', 'Время', 'Дата']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                Icon(
                                  _getTypeIcon(value),
                                  size: 20,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 12),
                                Text(value),
                              ],
                            ),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Пожалуйста, выберите тип данных';
                          }
                          return null;
                        },
                        onChanged: (String? newValue) {
                          setState(() {
                            _dataType = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _unitController,
                        decoration: InputDecoration(
                          labelText: 'Единица измерения (опционально)',
                          hintText: 'кг, см, баллы, часы и т.д.',
                          prefixIcon: const Icon(Icons.straighten),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _updateParameter,
                  icon: const Icon(Icons.save),
                  label: const Text('Сохранить изменения'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateParameter() async {
    final theme = Theme.of(context);
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Хотя save здесь не обязателен с контроллерами

      final updatedName = _nameController.text;
      final updatedUnit = _unitController.text;

      // Создаем обновленный объект Parameter, используя ID из исходного параметра
      final updatedParameter = widget.parameter.copyWith(
        name: updatedName,
        dataType: _dataType!,
        unit: updatedUnit.isEmpty ? null : updatedUnit,
        // scaleOptions пока не редактируем, но можно добавить логику и для них
      );

      try {
        await _parameterController.updateParameter(updatedParameter);

        Get.back(); // Возвращаемся на предыдущий экран (список)

        Get.snackbar( // Показываем снэкбар уже на экране списка
          'Успех',
          'Параметр "${updatedParameter.name}" успешно обновлен!',
          snackPosition: SnackPosition.BOTTOM
        );

      } catch (e) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('Ошибка при обновлении: $e'),
             backgroundColor: theme.colorScheme.error,
             behavior: SnackBarBehavior.floating,
           ),
         );
      }
    }
  }
  
  IconData _getTypeIcon(String dataType) {
    switch (dataType.toLowerCase()) {
      case 'число':
        return Icons.numbers;
      case 'текст':
        return Icons.text_fields;
      case 'оценка':
        return Icons.star_rate;
      case 'да/нет':
        return Icons.check_box;
      case 'время':
        return Icons.access_time;
      case 'дата':
        return Icons.date_range;
      default:
        return Icons.tune;
    }
  }
}