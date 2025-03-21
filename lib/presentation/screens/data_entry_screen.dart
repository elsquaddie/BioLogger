import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../domain/controllers/data_entry_controller.dart'; // Импорт DataEntryController

class DataEntryScreen extends StatefulWidget {
  const DataEntryScreen({Key? key}) : super(key: key);

  @override
  State<DataEntryScreen> createState() => _DataEntryScreenState();
}

class _DataEntryScreenState extends State<DataEntryScreen> {
  final DataEntryController _dataEntryController = Get.find<DataEntryController>();
  late TextEditingController _valueController;

  @override
  void initState() {
    super.initState();
    print("DataEntryScreen initState()");
    _valueController = TextEditingController();

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
        if (dailyRecord != null) {
          value = dailyRecord.dataValues[currentParameter.id.toString()]?.toString() ?? '';
          print('Found value for parameter ${currentParameter.id}: $value for date: ${normalizedDate.toIso8601String()}');
        } else {
          print('No record found for date: ${normalizedDate.toIso8601String()}');
        }

        setState(() {
          _valueController.text = value;
          // Обновляем значение в контроллере
          _dataEntryController.updateEnteredValue(currentParameter.id.toString(), value);
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _valueController.text = '';
        });
      }
    }
  }

  @override
  void dispose() {
    print("DataEntryScreen dispose()");
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ввод данных'),
      ),
      body: Obx(() { // Используем Obx для реактивности
        final currentParameter = _dataEntryController.currentParameter; // Получаем текущий параметр из контроллера

        if (currentParameter == null) {
          return const Center(child: Text("Все параметры заполнены!")); // Сообщение, когда все параметры введены
        }

        return Padding( // Добавляем Padding для отступов
          padding: const EdgeInsets.all(16.0),
          child: Column( // Используем Column для вертикального расположения элементов
            crossAxisAlignment: CrossAxisAlignment.start, // Выравнивание по левому краю
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Дата:', style: TextStyle(fontSize: 18)),
                  Obx(() => TextButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _dataEntryController.selectedDate.value,
                        firstDate: DateTime(2023),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        _dataEntryController.selectDate(pickedDate);
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd.MM.yyyy').format(_dataEntryController.selectedDate.value),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 20),
              Text( // Отображение названия текущего параметра
                currentParameter.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10), // Отступ

              TextFormField(
                key: ValueKey(currentParameter.id), // <--- ВОТ ЭТУ СТРОКУ ДОБАВЬ!
                controller: _valueController,
                decoration: const InputDecoration(labelText: 'Введите значение'),
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  _dataEntryController.updateEnteredValue(currentParameter.id.toString(), value);
                },
              ),

              const SizedBox(height: 20), // Отступ

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: _dataEntryController.currentParameterIndex.value > 0
                        ? () {
                            _dataEntryController.previousParameter();
                          }
                        : null,
                    style: _dataEntryController.currentParameterIndex.value == 0
                        ? ElevatedButton.styleFrom(disabledBackgroundColor: Colors.grey)
                        : null,
                    child: const Text("Назад"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _dataEntryController.nextParameter();
                    },
                    child: const Text("Далее"),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton( // Кнопка "Сохранить" (FAB)
        onPressed: () {
          _dataEntryController.saveDailyRecord(); // Вызов сохранения через контроллер
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}