import 'package:get/get.dart';

/// Контроллер для управления состоянием вкладки "Данные/Метрики"
/// Переключает между отображением метрик и списка параметров
class MetricsTabController extends GetxController {
  // Реактивная переменная для отслеживания текущего состояния
  var isShowingParameterList = false.obs;
  
  /// Показать экран списка параметров
  void showParameterList() {
    isShowingParameterList.value = true;
  }
  
  /// Показать экран метрик
  void showMetrics() {
    isShowingParameterList.value = false;
  }
  
  /// Переключить состояние между метриками и списком параметров
  void toggleView() {
    isShowingParameterList.value = !isShowingParameterList.value;
  }
  
  /// Геттер для проверки текущего состояния
  bool get isShowingMetrics => !isShowingParameterList.value;
}