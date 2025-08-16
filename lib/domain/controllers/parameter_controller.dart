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
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
        borderRadius: 12,
        duration: const Duration(seconds: 4),
      );
      rethrow;
    }
    // Finished loading parameters
  }

  Future<void> createParameter(Parameter parameter) async {
    try {
      // Вычисляем правильный sort_order - последний в списке + 1
      final maxSortOrder = parameters.isNotEmpty 
          ? parameters.map((p) => p.sortOrder).reduce((a, b) => a > b ? a : b)
          : -1;
      final newSortOrder = maxSortOrder + 1;
      
      // Создаем параметр с правильным sort_order
      final parameterWithSortOrder = parameter.copyWith(sortOrder: newSortOrder);
      
      final id = await _parameterRepository.insertParameter(parameterWithSortOrder);
      if (id != 0) {
        Parameter newParameter = parameterWithSortOrder.copyWith(id: id);
        parameters.add(newParameter);
        print("ParameterController: Created parameter '${newParameter.name}' with sort_order: $newSortOrder");
      }
    } catch (e) {
      print("Error creating parameter: $e");
      Get.snackbar(
        'Ошибка создания',
        'Не удалось создать параметр: $e',
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
        borderRadius: 12,
        duration: const Duration(seconds: 4),
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
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
        borderRadius: 12,
        duration: const Duration(seconds: 4),
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
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
        borderRadius: 12,
        duration: const Duration(seconds: 4),
      );
      rethrow;
    }
  }

  // Методы для работы с пресетами
  List<Parameter> get presetParameters => parameters.where((p) => p.isPreset).toList();
  List<Parameter> get userParameters => parameters.where((p) => !p.isPreset).toList();

  Future<void> toggleParameterEnabled(int id, bool isEnabled) async {
    try {
      await _parameterRepository.toggleParameterEnabled(id, isEnabled);
      final index = parameters.indexWhere((p) => p.id == id);
      if (index != -1) {
        parameters[index] = parameters[index].copyWith(isEnabled: isEnabled);
        parameters.refresh();
      }
    } catch (e) {
      print("Error toggling parameter: $e");
      Get.snackbar(
        'Ошибка переключения',
        'Не удалось изменить состояние параметра: $e',
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
        borderRadius: 12,
        duration: const Duration(seconds: 4),
      );
      rethrow;
    }
  }

  Future<void> reorderUserParameters(List<Parameter> reorderedParameters) async {
    try {
      // Обновляем sort_order для каждого параметра
      for (int i = 0; i < reorderedParameters.length; i++) {
        final parameter = reorderedParameters[i];
        if (!parameter.isPreset) {
          await _parameterRepository.updateParameterSortOrder(parameter.id!, i);
          final index = parameters.indexWhere((p) => p.id == parameter.id);
          if (index != -1) {
            parameters[index] = parameters[index].copyWith(sortOrder: i);
          }
        }
      }
      parameters.refresh();
    } catch (e) {
      print("Error reordering parameters: $e");
      Get.snackbar(
        'Ошибка изменения порядка',
        'Не удалось изменить порядок параметров: $e',
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
        borderRadius: 12,
        duration: const Duration(seconds: 4),
      );
      rethrow;
    }
  }

  Future<void> reorderAllParameters(List<Parameter> reorderedParameters) async {
    try {
      print("ParameterController: Reordering ${reorderedParameters.length} parameters");
      
      // Логируем старый и новый порядок для отладки
      print("Old order: ${parameters.map((p) => '${p.name}(${p.sortOrder})').toList()}");
      print("New order: ${reorderedParameters.map((p) => p.name).toList()}");
      
      // Обновляем sort_order в базе данных одной batch операцией (более эффективно)
      await _parameterRepository.updateParametersSortOrder(reorderedParameters);
      
      // Обновляем локальные объекты с новыми sort_order
      final updatedParameters = reorderedParameters.asMap().entries.map((entry) {
        final index = entry.key;
        final parameter = entry.value;
        return parameter.copyWith(sortOrder: index);
      }).toList();
      
      // Переупорядочиваем локальный список
      parameters.assignAll(updatedParameters);
      parameters.refresh();
      
      print("Updated order: ${parameters.map((p) => '${p.name}(${p.sortOrder})').toList()}");
    } catch (e) {
      print("Error reordering all parameters: $e");
      Get.snackbar(
        'Ошибка изменения порядка',
        'Не удалось изменить порядок параметров: $e',
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
        borderRadius: 12,
        duration: const Duration(seconds: 4),
      );
      rethrow;
    }
  }
}