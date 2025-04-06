// lib/presentation/screens/parameter_list_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/controllers/parameter_controller.dart';
import '../../models/parameter.dart';
import 'parameter_create_screen.dart';
import 'parameter_edit_screen.dart';

class ParameterListScreen extends StatelessWidget {
  ParameterListScreen({Key? key}) : super(key: key);

  final ParameterController _parameterController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список параметров'),
        // --- УДАЛИТЬ ИЛИ ЗАКОММЕНТИРОВАТЬ СЕКЦИЮ ACTIONS ---
        /*
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Создать параметр',
            onPressed: () {
              Get.to(() => const ParameterCreateScreen());
            },
          ),
        ],
        */
        // --- КОНЕЦ УДАЛЕНИЯ ---
      ),
      body: Obx(() { // Используем Obx для реактивного обновления при изменении списка
        if (!_parameterController.isParametersLoaded.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (_parameterController.parameters.isEmpty) {
          return const Center(
            child: Text(
              'Пока нет ни одного параметра.\nНажмите "+", чтобы создать первый.',
              textAlign: TextAlign.center,
            ),
          );
        } else {
          return ListView.builder(
            itemCount: _parameterController.parameters.length,
            itemBuilder: (context, index) {
              final parameter = _parameterController.parameters[index];
              return ListTile(
                title: Text(parameter.name),
                subtitle: Text('Тип: ${parameter.dataType}${parameter.unit != null && parameter.unit!.isNotEmpty ? ', Ед.изм: ${parameter.unit}' : ''}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      tooltip: 'Редактировать',
                      onPressed: () {
                        Get.to(() => ParameterEditScreen(parameter: parameter));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Удалить',
                      onPressed: () {
                        _showDeleteConfirmationDialog(context, parameter);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        }
      }),
      // --- ДОБАВИТЬ ИЛИ РАСКОММЕНТИРОВАТЬ ЭТОТ БЛОК ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Переход на экран создания параметра
          Get.to(() => const ParameterCreateScreen());
        },
        tooltip: 'Создать параметр', // Подсказка
        child: const Icon(Icons.add), // Иконка плюса
      ),
      // --- КОНЕЦ ДОБАВЛЕНИЯ ---
    );
  }

  // Метод _showDeleteConfirmationDialog остается без изменений
  void _showDeleteConfirmationDialog(BuildContext context, Parameter parameter) {
    // ... (код диалога как и был) ...
        showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Подтверждение удаления'),
          content: Text('Вы уверены, что хотите удалить параметр "${parameter.name}"? Это действие нельзя будет отменить.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Отмена'),
              onPressed: () {
                Get.back(); // Закрыть диалог
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Удалить'),
              onPressed: () async {
                Get.back(); // Закрыть диалог
                try {
                  // Вызываем метод удаления в контроллере
                  await _parameterController.deleteParameter(parameter.id!);
                  Get.snackbar(
                    'Успех',
                    'Параметр "${parameter.name}" удален.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                } catch (e) {
                  Get.snackbar(
                    'Ошибка',
                    'Не удалось удалить параметр: $e',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}