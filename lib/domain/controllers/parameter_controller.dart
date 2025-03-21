import 'package:get/get.dart';
import '../../models/parameter.dart';
import '../../data/repositories/parameter_repository.dart';
import '../../data/repositories/parameter_repository_impl.dart';

class ParameterController extends GetxController {
  final ParameterRepository _parameterRepository = ParameterRepositoryImpl(); // Используем реализацию репозитория
  final parameters = <Parameter>[].obs; // Observable список параметров для GetX
  final isParametersLoaded = false.obs; // Add an observable flag

  @override
  void onInit() {
    super.onInit();
    loadParameters().then((_) {
      isParametersLoaded.value = true;
    });
  }

  Future<void> loadParameters() async {
    print("ParameterController: loadParameters() - Start loading parameters from database...");

    try {
      final loadedParameters = await _parameterRepository.getAllParameters();
      parameters.assignAll(loadedParameters);

      print("ParameterController: loadParameters() - Parameters loaded successfully. Count: ${loadedParameters.length}");
      if (loadedParameters.isNotEmpty) {
        print("ParameterController: loadParameters() - Loaded parameters: ${loadedParameters.map((p) => p.name).toList()}");
      } else {
        print("ParameterController: loadParameters() - No parameters found in database.");
      }

    } catch (e) {
      print("ParameterController: loadParameters() - Error loading parameters: $e");
      // TODO: Обработка ошибок
      print("Error loading parameters: $e");
    }
    print("ParameterController: loadParameters() - Finished loading parameters.");
  }

  Future<void> createParameter(Parameter parameter) async {
    try {
      final id = await _parameterRepository.insertParameter(parameter);
      if (id != 0) {
        Parameter newParameter = parameter.copyWith(id: id); // Создаем новый Parameter с ID, который вернула БД
        parameters.add(newParameter); // Добавляем новый параметр в observable список
      }
    } catch (e) {
      // TODO: Обработка ошибок
      print("Error creating parameter: $e");
    }
  }

  Future<void> updateParameter(Parameter parameter) async {
    try {
      await _parameterRepository.updateParameter(parameter);
      final index = parameters.indexWhere((p) => p.id == parameter.id);
      if (index != -1) {
        parameters[index] = parameter; // Обновляем параметр в observable списке
        parameters.refresh(); // Явно уведомляем GetX об изменении списка (если нужно)
      }
    } catch (e) {
      // TODO: Обработка ошибок
      print("Error updating parameter: $e");
    }
  }

  Future<void> deleteParameter(int id) async {
    try {
      await _parameterRepository.deleteParameter(id);
      parameters.removeWhere((p) => p.id == id); // Удаляем параметр из observable списка
    } catch (e) {
      // TODO: Обработка ошибок
      print("Error deleting parameter: $e");
    }
  }
}