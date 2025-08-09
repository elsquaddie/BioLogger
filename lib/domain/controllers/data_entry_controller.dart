import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/parameter.dart';
import '../../domain/controllers/parameter_controller.dart'; // Импорт ParameterController
import '../../data/repositories/daily_record_repository_impl.dart';
import '../../models/daily_record.dart';

class DataEntryController extends GetxController {
  final ParameterController _parameterController = Get.find<ParameterController>();
  final _dailyRecordRepository = DailyRecordRepositoryImpl();

  final parametersForEntry = <Parameter>[].obs;
  final enteredValues = <String, dynamic>{}.obs;
  final currentParameterIndex = 0.obs;
  Rx<DateTime> selectedDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    selectDate(DateTime.now());

    // Слушаем изменения в списке параметров ParameterController
    ever(_parameterController.parameters, (updatedParameters) { // <--- СЛУШАЕМ parameters, А НЕ isParametersLoaded
      _loadParametersForEntryForDate(selectedDate.value); // <--- Перезагружаем параметры при изменении списка в ParameterController
    });
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    _loadParametersForEntryForDate(date);
  }

  void _loadParametersForEntryForDate(DateTime selectedDate) async {
    final normalizedDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final dailyRecord = await loadDailyRecordForDate(normalizedDate);
    final allParameters = _parameterController.parameters; // <--- Берем параметры ИЗ ParameterController напрямую
    parametersForEntry.assignAll(allParameters);

    enteredValues.clear();
    for (var parameter in parametersForEntry) {
      final parameterId = parameter.id.toString();
      if (dailyRecord != null && dailyRecord.dataValues.containsKey(parameterId)) {
        enteredValues[parameterId] = dailyRecord.dataValues[parameterId];
      } else {
        enteredValues[parameterId] = '';
      }
    }
    if (parametersForEntry.isNotEmpty) {
      currentParameterIndex.value = 0; // <--- Сбрасываем индекс на 0 при загрузке новых параметров
    } else {
      currentParameterIndex.value = -1; // или -1, если параметров нет
    }
    update(); // <---  ОБНОВЛЯЕМ UI после загрузки параметров
  }

  Parameter? get currentParameter =>
      parametersForEntry.isNotEmpty && currentParameterIndex.value < parametersForEntry.length
          ? parametersForEntry[currentParameterIndex.value]
          : null;

  bool get isLastParameter =>
      parametersForEntry.isNotEmpty && currentParameterIndex.value == parametersForEntry.length - 1;

  void updateEnteredValue(String parameterId, dynamic value) {
    enteredValues[parameterId] = value;
  }

  void nextParameter() {
    if (currentParameterIndex.value < parametersForEntry.length - 1) {
      currentParameterIndex.value++;
    } else {
      // На последнем параметре - сохраняем данные
      saveDailyRecord();
    }
  }

  void previousParameter() {
    if (currentParameterIndex.value > 0) {
      currentParameterIndex.value--;
    } else {
      print("Already at the first parameter.");
    }
  }

  Future<void> saveDailyRecord() async {
    print("Сохранение ежедневной записи...");
    
    final dataValuesMap = <String, dynamic>{};
    for (var parameter in parametersForEntry) {
      final value = enteredValues[parameter.id.toString()];
      if (value != null && value.toString().isNotEmpty) {
        dataValuesMap[parameter.id.toString()] = value;
      }
    }

    final normalizedDate = DateTime(selectedDate.value.year, selectedDate.value.month, selectedDate.value.day);
    final dailyRecord = DailyRecord(
      date: normalizedDate,
      dataValues: dataValuesMap,
    );

    try {
      await _dailyRecordRepository.insertDailyRecord(dailyRecord);
      print("Ежедневная запись успешно сохранена!");
      Get.snackbar(
        'Успех',
        'Данные сохранены за ${DateFormat('dd.MM.yyyy').format(selectedDate.value)}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print("Ошибка сохранения ежедневной записи: $e");
      Get.snackbar(
        'Ошибка',
        'Не удалось сохранить данные',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<DailyRecord?> loadDailyRecordForDate(DateTime date) async {
    print("Загрузка ежедневной записи за дату: $date");
    final dailyRecord = await _dailyRecordRepository.getDailyRecordByDate(date);

    if (dailyRecord != null) {
      print("Запись найдена! Data from database: ${dailyRecord.dataValues}");
      enteredValues.assignAll(dailyRecord.dataValues.map((key, value) => MapEntry(key, value)));
    } else {
      print("Запись не найдена");
      enteredValues.clear();
      for (var parameter in parametersForEntry) {
        enteredValues[parameter.id.toString()] = '';
      }
    }
    return dailyRecord;
  }

  // Add this public method
  Future<DailyRecord?> getDailyRecordByDate(DateTime date) async {
    return await _dailyRecordRepository.getDailyRecordByDate(date);
  }
}