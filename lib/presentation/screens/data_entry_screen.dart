import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  }

  Future<void> _updateTextFieldForParameter() async {
    final currentParameter = _dataEntryController.currentParameter;
    if (currentParameter != null) {
      final now = DateTime.now();
      final normalizedDate = DateTime(now.year, now.month, now.day);
      
      // Получаем запись напрямую из базы данных
      final dailyRecord = await _dataEntryController.getDailyRecordByDate(normalizedDate);

      if (mounted) {
        String value = '';
        if (dailyRecord != null) {
          value = dailyRecord.dataValues[currentParameter.id.toString()]?.toString() ?? '';
          print('Found value for parameter ${currentParameter.id}: $value');
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