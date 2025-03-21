import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'parameter_edit_screen.dart'; // Импорт экрана редактора параметров
import 'data_entry_screen.dart';      // Импорт экрана ввода данных
import '../../domain/controllers/daily_record_controller.dart';

class HomeScreen extends StatelessWidget {
  final DailyRecordController dailyRecordController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('БиоЛог'),
        centerTitle: true, // Выравнивание заголовка по центру
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch, // Растягиваем кнопки на всю ширину
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Get.to(() => ParameterEditScreen()); // Переход к экрану редактора параметров
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0), // Увеличиваем вертикальный отступ
                  child: Text('Редактор параметров', style: TextStyle(fontSize: 18)), // Увеличиваем размер шрифта
                ),
              ),
              SizedBox(height: 20), // Отступ между кнопками
              ElevatedButton(
                onPressed: () {
                  Get.to(() => DataEntryScreen()); // Переход к экрану ввода данных
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0), // Увеличиваем вертикальный отступ
                  child: Text('Ввод данных за день', style: TextStyle(fontSize: 18)), // Увеличиваем размер шрифта
                ),
              ),
              SizedBox(height: 20), // Отступ между кнопками
              ElevatedButton(
                onPressed: () => dailyRecordController.exportDataToCsv(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text('Экспорт данных в CSV', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}