import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/parameter.dart';
import '../../data/repositories/parameter_repository.dart';
import '../../data/repositories/parameter_repository_impl.dart';

class ParameterController extends GetxController {
  final ParameterRepository _parameterRepository;
  ParameterController(this._parameterRepository);

  final parameters = <Parameter>[].obs;
  final isParametersLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadParameters().then((_) {
      isParametersLoaded.value = true;
    });
  }

  Future<void> loadParameters() async {
    // Loading parameters from database

    try {
      final loadedParameters = await _parameterRepository.getAllParameters();
      parameters.assignAll(loadedParameters);

      // Parameters loaded successfully: ${loadedParameters.length} items

    } catch (e) {
      // Error loading parameters: $e
      Get.snackbar(
        'Ошибка загрузки',
        'Не удалось загрузить параметры: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    }
    // Finished loading parameters
  }

  Future<void> createParameter(Parameter parameter) async {
    try {
      final id = await _parameterRepository.insertParameter(parameter);
      if (id != 0) {
        Parameter newParameter = parameter.copyWith(id: id);
        parameters.add(newParameter);
      }
    } catch (e) {
      print("Error creating parameter: $e");
      Get.snackbar(
        'Ошибка создания',
        'Не удалось создать параметр: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    }
  }

  Future<void> updateParameter(Parameter parameter) async {
    try {
      await _parameterRepository.updateParameter(parameter);
      final index = parameters.indexWhere((p) => p.id == parameter.id);
      if (index != -1) {
        parameters[index] = parameter;
        parameters.refresh();
      }
    } catch (e) {
      print("Error updating parameter: $e");
      Get.snackbar(
        'Ошибка обновления',
        'Не удалось обновить параметр: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    }
  }

  Future<void> deleteParameter(int id) async {
    try {
      final index = parameters.indexWhere((p) => p.id == id);
      if (index == -1) return;

      await _parameterRepository.deleteParameter(id);
      parameters.removeWhere((p) => p.id == id);
    } catch (e) {
      print("Error deleting parameter: $e");
      Get.snackbar(
        'Ошибка удаления',
        'Не удалось удалить параметр: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    }
  }
}