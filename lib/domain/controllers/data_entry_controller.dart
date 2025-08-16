import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/parameter.dart';
import '../../domain/controllers/parameter_controller.dart'; // Импорт ParameterController
import '../../domain/controllers/home_controller.dart'; // Импорт HomeController
import '../../presentation/screens/main_navigation_screen.dart'; // Импорт NavigationController
import '../../data/repositories/daily_record_repository_impl.dart';
import '../../models/daily_record.dart';

class DataEntryController extends GetxController {
  final ParameterController _parameterController = Get.find<ParameterController>();
  final _dailyRecordRepository = DailyRecordRepositoryImpl();

  final parametersForEntry = <Parameter>[].obs;
  final enteredValues = <String, dynamic>{}.obs;
  final enteredComments = <String, String>{}.obs;
  final currentParameterIndex = 0.obs;
  
  // Отладочный метод для отслеживания изменений индекса
  void setCurrentParameterIndex(int newIndex, String reason) {
    print("DataEntryController: Setting currentParameterIndex from ${currentParameterIndex.value} to $newIndex. Reason: $reason");
    currentParameterIndex.value = newIndex;
  }
  final _requestedParameterId = Rx<int?>(null); // Запрошенный ID параметра для навигации
  Rx<DateTime> selectedDate = DateTime.now().obs;
  final initialViewMode = 'list'.obs; // 'list' для превью, 'edit' для редактирования

  @override
  void onInit() {
    super.onInit();
    // Получаем выбранную дату из HomeController если он существует
    try {
      final homeController = Get.find<HomeController>();
      selectedDate.value = homeController.selectedDate.value;
    } catch (e) {
      // Если HomeController не найден, используем сегодняшнюю дату
      selectedDate.value = DateTime.now();
    }
    
    _loadParametersForEntryForDate(selectedDate.value);

    // Слушаем изменения в списке параметров ParameterController
    ever(_parameterController.parameters, (updatedParameters) { // <--- СЛУШАЕМ parameters, А НЕ isParametersLoaded
      _loadParametersForEntryForDate(selectedDate.value); // <--- Перезагружаем параметры при изменении списка в ParameterController
    });
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    _loadParametersForEntryForDate(date);
  }
  
  void setInitialViewMode(String mode) {
    initialViewMode.value = mode;
    // НЕ сбрасываем индекс автоматически - он должен быть установлен вызывающим кодом
    // if (mode == 'edit') {
    //   currentParameterIndex.value = 0;
    // }
  }
  
  /// НОВАЯ ФУНКЦИЯ: Устанавливает параметр для навигации по ID
  void setParameterForNavigation(int parameterId) {
    print("DataEntryController: setParameterForNavigation called with ID: $parameterId");
    _requestedParameterId.value = parameterId;
    
    // Если параметры уже загружены, сразу устанавливаем индекс
    if (parametersForEntry.isNotEmpty) {
      _setCurrentParameterByRequestedId();
    }
  }

  void _loadParametersForEntryForDate(DateTime selectedDate) async {
    final normalizedDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final dailyRecord = await loadDailyRecordForDate(normalizedDate);
    // Берем только включенные параметры (где isEnabled = true)
    final enabledParameters = _parameterController.parameters.where((param) => param.isEnabled).toList();
    parametersForEntry.assignAll(enabledParameters);

    enteredValues.clear();
    enteredComments.clear();
    for (var parameter in parametersForEntry) {
      final parameterId = parameter.id.toString();
      if (dailyRecord != null && dailyRecord.dataValues.containsKey(parameterId)) {
        enteredValues[parameterId] = dailyRecord.dataValues[parameterId];
      } else {
        enteredValues[parameterId] = '';
      }
      
      if (dailyRecord != null && dailyRecord.comments.containsKey(parameterId)) {
        enteredComments[parameterId] = dailyRecord.comments[parameterId]!;
      } else {
        enteredComments[parameterId] = '';
      }
    }
    // КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ: НЕ сбрасываем индекс на 0!
    // Вместо этого устанавливаем правильный индекс на основе запрошенного параметра
    if (parametersForEntry.isNotEmpty) {
      _setCurrentParameterByRequestedId();
    } else {
      currentParameterIndex.value = -1; // только если параметров нет
    }
    update(); // ОБНОВЛЯЕМ UI после загрузки параметров
  }

  /// НОВАЯ ФУНКЦИЯ: Устанавливает индекс на основе запрошенного ID параметра
  void _setCurrentParameterByRequestedId() {
    if (_requestedParameterId.value != null && parametersForEntry.isNotEmpty) {
      final requestedId = _requestedParameterId.value!;
      final foundIndex = parametersForEntry.indexWhere((p) => p.id == requestedId);
      
      print("DataEntryController: Looking for parameter ID $requestedId");
      print("DataEntryController: Available parameters: ${parametersForEntry.map((p) => '${p.name}(${p.id})').toList()}");
      print("DataEntryController: Found at index: $foundIndex");
      
      if (foundIndex != -1) {
        setCurrentParameterIndex(foundIndex, "Found requested parameter ID $requestedId at index $foundIndex (${parametersForEntry[foundIndex].name})");
      } else {
        // Если запрошенный параметр не найден, устанавливаем 0
        setCurrentParameterIndex(0, "Requested parameter ID $requestedId not found, defaulting to index 0");
      }
      
      // Очищаем запрошенный ID после установки
      _requestedParameterId.value = null;
    } else {
      // КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ: Сохраняем текущий параметр при переупорядочивании
      // Если есть текущий параметр, пытаемся сохранить его позицию по ID
      if (parametersForEntry.isNotEmpty && currentParameterIndex.value >= 0 && currentParameterIndex.value < parametersForEntry.length) {
        final currentParam = parametersForEntry[currentParameterIndex.value];
        final currentParamId = currentParam.id;
        
        // Ищем тот же параметр в новом списке после переупорядочивания
        final newIndex = parametersForEntry.indexWhere((p) => p.id == currentParamId);
        if (newIndex != -1 && newIndex != currentParameterIndex.value) {
          print("DataEntryController: Parameter '${currentParam.name}' moved from index ${currentParameterIndex.value} to $newIndex");
          setCurrentParameterIndex(newIndex, "Adjusted index after reordering for parameter ${currentParam.name}");
        } else {
          print("DataEntryController: Current parameter ${currentParam.name} remains at index ${currentParameterIndex.value}");
        }
      } else {
        // Если нет текущего параметра, устанавливаем 0 (по умолчанию)
        setCurrentParameterIndex(0, "No current parameter, defaulting to index 0");
      }
    }
  }

  Parameter? get currentParameter =>
      parametersForEntry.isNotEmpty && currentParameterIndex.value >= 0 && currentParameterIndex.value < parametersForEntry.length
          ? parametersForEntry[currentParameterIndex.value]
          : null;

  bool get isLastParameter =>
      parametersForEntry.isNotEmpty && currentParameterIndex.value == parametersForEntry.length - 1;

  void updateEnteredValue(String parameterId, dynamic value) {
    enteredValues[parameterId] = value;
  }

  void updateEnteredComment(String parameterId, String comment) {
    enteredComments[parameterId] = comment;
  }

  void nextParameter() {
    print("DataEntryController: nextParameter called. Current index: ${currentParameterIndex.value}, Total parameters: ${parametersForEntry.length}");
    
    if (parametersForEntry.isEmpty) {
      print("DataEntryController: No parameters available for navigation");
      return;
    }
    
    if (currentParameterIndex.value < parametersForEntry.length - 1) {
      setCurrentParameterIndex(currentParameterIndex.value + 1, "User clicked Next button");
    } else {
      // На последнем параметре - сохраняем данные
      print("DataEntryController: On last parameter, saving data");
      saveDailyRecord();
    }
  }

  void previousParameter() {
    print("DataEntryController: previousParameter called. Current index: ${currentParameterIndex.value}, Total parameters: ${parametersForEntry.length}");
    
    if (parametersForEntry.isEmpty) {
      print("DataEntryController: No parameters available for navigation");
      return;
    }
    
    if (currentParameterIndex.value > 0) {
      setCurrentParameterIndex(currentParameterIndex.value - 1, "User clicked Previous button");
    } else {
      print("DataEntryController: Already at first parameter");
    }
  }

  Future<void> saveDailyRecord() async {
    // Убираем клавиатуру в самом начале, перед всеми операциями
    FocusManager.instance.primaryFocus?.unfocus();
    
    final dataValuesMap = <String, dynamic>{};
    final commentsMap = <String, String>{};
    
    for (var parameter in parametersForEntry) {
      final parameterId = parameter.id.toString();
      final value = enteredValues[parameterId];
      final comment = enteredComments[parameterId];
      
      if (value != null && value.toString().isNotEmpty) {
        dataValuesMap[parameterId] = value;
      }
      
      if (comment != null && comment.isNotEmpty) {
        commentsMap[parameterId] = comment;
      }
    }

    final normalizedDate = DateTime(selectedDate.value.year, selectedDate.value.month, selectedDate.value.day);
    final dailyRecord = DailyRecord(
      date: normalizedDate,
      dataValues: dataValuesMap,
      comments: commentsMap,
    );

    try {
      await _dailyRecordRepository.insertDailyRecord(dailyRecord);
      // Daily record saved successfully
      
      // Реактивно обновляем HomeController после сохранения
      try {
        final homeController = Get.find<HomeController>();
        await homeController.loadFilledDays();
        homeController.updateCounters();
      } catch (e) {
        print('HomeController не найден для обновления: $e');
      }
      
      // Переключаемся обратно на главную вкладку через NavigationController
      try {
        final navigationController = Get.find<NavigationController>();
        navigationController.goToHome();
      } catch (e) {
        print('NavigationController не найден для навигации: $e');
      }
      
      Get.snackbar(
        'Успех',
        'Данные сохранены за ${DateFormat('dd.MM.yyyy').format(selectedDate.value)}',
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      // Error saving daily record: $e
      Get.snackbar(
        'Ошибка',
        'Не удалось сохранить данные',
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
        borderRadius: 12,
        duration: const Duration(seconds: 4),
      );
    }
  }

  Future<DailyRecord?> loadDailyRecordForDate(DateTime date) async {
    // Loading daily record for date: $date
    final dailyRecord = await _dailyRecordRepository.getDailyRecordByDate(date);

    if (dailyRecord != null) {
      // Record found with data and comments
      enteredValues.assignAll(dailyRecord.dataValues.map((key, value) => MapEntry(key, value)));
      enteredComments.assignAll(dailyRecord.comments);
    } else {
      // Record not found
      enteredValues.clear();
      enteredComments.clear();
      for (var parameter in parametersForEntry) {
        enteredValues[parameter.id.toString()] = '';
        enteredComments[parameter.id.toString()] = '';
      }
    }
    return dailyRecord;
  }

  // Add this public method
  Future<DailyRecord?> getDailyRecordByDate(DateTime date) async {
    return await _dailyRecordRepository.getDailyRecordByDate(date);
  }
}