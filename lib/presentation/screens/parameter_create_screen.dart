import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/parameter.dart';
import '../../domain/controllers/parameter_controller.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать параметр'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Название параметра'),
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
                decoration: const InputDecoration(labelText: 'Тип данных'),
                value: _dataType,
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
                onSaved: (value) {
                  _dataType = value;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Единица измерения (опционально)'),
                onSaved: (value) {
                  _unit = value ?? '';
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveParameter,
                child: const Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveParameter() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      print('Название параметра: $_parameterName');
      print('Тип данных: $_dataType');
      print('Единица измерения: $_unit');

      final newParameter = Parameter(
        name: _parameterName,
        dataType: _dataType!,
        unit: _unit.isEmpty ? null : _unit,
      );

      try {
        await _parameterController.createParameter(newParameter);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Параметр успешно сохранен!')),
        );

        _formKey.currentState!.reset();
        setState(() {
          _dataType = null;
          _parameterName = '';
          _unit = '';
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при сохранении: $e')),
        );
      }
    }
  }
}