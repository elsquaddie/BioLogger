import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/controllers/home_controller.dart';
import '../../domain/controllers/data_entry_controller.dart';
import '../../domain/controllers/metrics_tab_controller.dart';
import '../theme/app_theme.dart';
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

    return PopScope(
      canPop: false, // Предотвращаем автоматический выход из приложения
      onPopInvoked: (didPop) {
        if (didPop) return; // Если уже обработано, не делаем ничего
        
        _handleBackPress(navigationController);
      },
      child: Scaffold(
        body: Obx(() => AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0), // Въезжает справа
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: Container(
            key: ValueKey(navigationController.currentIndex.value),
            child: screens[navigationController.currentIndex.value],
          ),
        )),
        bottomNavigationBar: Obx(() => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Color(0xFFE5E7EB), // border-t color
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  _buildNavItem(
                    icon: Icons.grid_view,
                    label: 'Главная',
                    isActive: navigationController.currentIndex.value == 0,
                    onTap: () => navigationController.changeTab(0),
                  ),
                  _buildNavItem(
                    icon: Icons.check_circle,
                    label: 'Запись',
                    isActive: navigationController.currentIndex.value == 1,
                    onTap: () {
                      // При нажатии на "Ввод" устанавливаем текущую дату и режим списка
                      final today = DateTime.now();
                      homeController.selectDate(today);
                      
                      try {
                        final dataEntryController = Get.find<DataEntryController>();
                        dataEntryController.selectDate(today);
                        dataEntryController.setInitialViewMode('list');
                      } catch (e) {
                        print('DataEntryController не найден при переходе на ввод: $e');
                      }
                      navigationController.changeTab(1);
                    },
                  ),
                  _buildNavItem(
                    icon: Icons.insights,
                    label: 'Данные',
                    isActive: navigationController.currentIndex.value == 2,
                    onTap: () => navigationController.changeTab(2),
                  ),
                  _buildNavItem(
                    icon: Icons.settings,
                    label: 'Настройки',
                    isActive: navigationController.currentIndex.value == 3,
                    onTap: () => navigationController.changeTab(3),
                  ),
                ],
              ),
            ),
          ),
        )),
      ),
    );
  }
  
  /// Создает элемент навигации в стиле макета
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppTheme.brandGreen : const Color(0xFF6B7280),
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? AppTheme.brandGreen : const Color(0xFF6B7280),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Обработка нажатия системной кнопки "Назад"
  void _handleBackPress(NavigationController navigationController) {
    try {
      // Проверяем, находимся ли мы на экране ввода данных в режиме редактирования
      if (navigationController.currentIndex.value == 1) {
        final dataEntryController = Get.find<DataEntryController>();
        if (dataEntryController.initialViewMode.value == 'edit') {
          // Возвращаемся к списку параметров
          dataEntryController.setInitialViewMode('list');
          return;
        }
      }
    } catch (e) {
      // DataEntryController может быть не инициализирован
    }

    try {
      // Проверяем, находимся ли мы на экране метрик с открытым списком параметров
      final metricsTabController = Get.find<MetricsTabController>();
      if (navigationController.currentIndex.value == 2 && 
          metricsTabController.isShowingParameterList.value) {
        // Возвращаемся к метрикам
        metricsTabController.showMetrics();
        return;
      }
    } catch (e) {
      // MetricsTabController может быть не инициализирован
    }

    // Проверяем, находимся ли мы на вкладке, отличной от главной
    if (navigationController.currentIndex.value != 0) {
      // Переключаемся на главную вкладку
      navigationController.goToHome();
      return;
    }

    // Если мы уже на главной вкладке, выходим из приложения
    Get.back();
  }
}

/// Расширение для легкого доступа к NavigationController
extension NavigationExtension on BuildContext {
  NavigationController get navigation => Get.find<NavigationController>();
}