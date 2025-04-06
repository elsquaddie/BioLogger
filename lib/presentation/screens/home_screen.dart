// lib/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'parameter_create_screen.dart'; // Больше не нужен прямой переход отсюда
import 'parameter_list_screen.dart'; // <--- ИМПОРТ нового экрана
import 'data_entry_screen.dart';
import '../../domain/controllers/daily_record_controller.dart';
// Возможно, понадобится ParameterController, если ты захочешь здесь что-то связанное с параметрами делать
// import '../../domain/controllers/parameter_controller.dart';

class HomeScreen extends StatelessWidget {
  final DailyRecordController dailyRecordController = Get.find();
  // Если ParameterController используется только на экране списка, его здесь можно не находить
  // final ParameterController parameterController = Get.find();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('БиоЛог'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  // --- ИЗМЕНЕНИЕ ЗДЕСЬ ---
                  // Переходим на экран списка параметров
                  Get.to(() => ParameterListScreen());
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  // Можно изменить текст, если хочешь
                  child: Text('Параметры', style: TextStyle(fontSize: 18)),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Get.to(() => DataEntryScreen());
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text('Ввод данных за день', style: TextStyle(fontSize: 18)),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => dailyRecordController.exportDataAndShare(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text('Экспорт / Поделиться', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}