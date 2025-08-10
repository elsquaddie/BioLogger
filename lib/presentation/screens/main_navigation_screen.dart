import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/controllers/home_controller.dart';
import '../../domain/controllers/data_entry_controller.dart';
import 'home_screen.dart';
import 'data_entry_screen.dart';
import 'metrics_screen.dart';
import 'settings_screen.dart';

/// Контроллер для управления навигацией между вкладками
class NavigationController extends GetxController {
  var currentIndex = 0.obs;
  
  void changeTab(int index) {
    currentIndex.value = index;
  }
  
  /// Переход на вкладку "Ввод" (индекс 1)
  void goToDataEntry() {
    // При переходе по вкладке всегда показываем список-превью
    try {
      final dataEntryController = Get.find<DataEntryController>();
      dataEntryController.setInitialViewMode('list');
    } catch (e) {
      // DataEntryController может быть не инициализирован
    }
    changeTab(1);
  }
  
  /// Переход на главную вкладку (индекс 0)
  void goToHome() {
    changeTab(0);
  }
}

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController = Get.put(NavigationController());
    final HomeController homeController = Get.find<HomeController>();
    final theme = Theme.of(context);

    // Слушаем изменения выбранной даты в календаре 
    ever(homeController.selectedDate, (DateTime selectedDate) {
      // Только обновляем дату в DataEntryController, без автонавигации
      try {
        final dataEntryController = Get.find<DataEntryController>();
        dataEntryController.selectDate(selectedDate);
      } catch (e) {
        // DataEntryController может быть не инициализирован
        print('DataEntryController не найден: $e');
      }
    });

    final List<Widget> screens = [
      const HomeScreen(),        // 0 - Главная
      const DataEntryScreen(),   // 1 - Ввод
      const MetricsScreen(),     // 2 - Метрики
      const SettingsScreen(),    // 3 - Настройки
    ];

    return Scaffold(
      body: Obx(() => IndexedStack(
        index: navigationController.currentIndex.value,
        children: screens,
      )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: navigationController.currentIndex.value,
        onTap: (index) {
          if (index == 1) {
            // При нажатии на "Ввод" устанавливаем текущую дату и режим списка
            final today = DateTime.now();
            homeController.selectDate(today);
            
            try {
              final dataEntryController = Get.find<DataEntryController>();
              dataEntryController.selectDate(today);
              dataEntryController.setInitialViewMode('list'); // Всегда показываем список при переходе по вкладке
            } catch (e) {
              print('DataEntryController не найден при переходе на ввод: $e');
            }
          }
          navigationController.changeTab(index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.colorScheme.surface,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_task_outlined),
            activeIcon: Icon(Icons.add_task),
            label: 'Запись',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Данные',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      )),
    );
  }
}

/// Расширение для легкого доступа к NavigationController
extension NavigationExtension on BuildContext {
  NavigationController get navigation => Get.find<NavigationController>();
}