import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../domain/controllers/parameter_controller.dart';
import '../../presentation/screens/parameter_create_screen.dart';

class ParameterEditScreen extends StatelessWidget {
  const ParameterEditScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ParameterController controller = Get.find<ParameterController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактор параметров'),
      ),
      body: Obx(() =>
          ListView.builder(
            itemCount: controller.parameters.length,
            itemBuilder: (context, index) {
              final parameter = controller.parameters[index];
              return ListTile(
                title: Text(parameter.name),
              );
            },
          ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const ParameterCreateScreen());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}