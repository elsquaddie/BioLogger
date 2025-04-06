// lib/presentation/screens/parameter_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/parameter.dart';
import '../../domain/controllers/parameter_controller.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать параметр'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _nameController, // Используем контроллер
                decoration: const InputDecoration(labelText: 'Название параметра'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите название параметра';
                  }
                  return null;
                },
                // onSaved не нужен при использовании контроллера
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Тип данных'),
                value: _dataType, // Предзаполненное значение
                items: <String>['Число', 'Текст', 'Оценка', 'Да/Нет', 'Время', 'Дата']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
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
                // onSaved не нужен, значение уже в _dataType
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _unitController, // Используем контроллер
                decoration: const InputDecoration(labelText: 'Единица измерения (опционально)'),
                // onSaved не нужен
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _updateParameter, // Вызываем метод обновления
                child: const Text('Сохранить изменения'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateParameter() async {
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
         // Показываем ошибку здесь же, если не удалось обновить
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Ошибка при обновлении: $e')),
         );
      }
    }
  }
}