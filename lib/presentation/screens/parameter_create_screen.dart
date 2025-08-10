import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/parameter.dart';
import '../../domain/controllers/parameter_controller.dart';
import '../theme/app_theme.dart';

class ParameterCreateScreen extends StatefulWidget {
  const ParameterCreateScreen({Key? key}) : super(key: key);

  @override
  State<ParameterCreateScreen> createState() => _ParameterCreateScreenState();
}
class _ParameterCreateScreenState extends State<ParameterCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _parameterController = Get.find<ParameterController>();
  String _parameterName = '';
  String? _dataType;
  String _unit = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Создать параметр'),
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
                            Icons.tune,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Информация о параметре',
                            style: theme.textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
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
                        onSaved: (value) {
                          _parameterName = value!;
                        },
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Тип данных',
                          hintText: 'Выберите тип',
                          prefixIcon: const Icon(Icons.category_outlined),
                        ),
                        value: _dataType,
                        items: <String>['Число', 'Текст', 'Оценка', 'Да/Нет']
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
                        onSaved: (value) {
                          _dataType = value;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Единица измерения (опционально)',
                          hintText: 'кг, см, баллы, часы и т.д.',
                          prefixIcon: const Icon(Icons.straighten),
                        ),
                        onSaved: (value) {
                          _unit = value ?? '';
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveParameter,
                  icon: const Icon(Icons.save),
                  label: const Text('Создать параметр'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveParameter() async {
    final theme = Theme.of(context);
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Parameter creation data processed

      final newParameter = Parameter(
        name: _parameterName,
        dataType: _dataType!,
        unit: _unit.isEmpty ? null : _unit,
      );

      try {
        await _parameterController.createParameter(newParameter);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Параметр "$_parameterName" создан успешно!'),
            backgroundColor: theme.colorScheme.primaryContainer,
            behavior: SnackBarBehavior.floating,
          ),
        );

        _formKey.currentState!.reset();
        setState(() {
          _dataType = null;
          _parameterName = '';
          _unit = '';
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при сохранении: $e'),
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