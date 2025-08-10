import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'presentation/screens/main_navigation_screen.dart';
import 'presentation/theme/app_theme.dart';
import 'data/repositories/daily_record_repository.dart';
import 'data/repositories/daily_record_repository_impl.dart';
import 'data/repositories/parameter_repository.dart';
import 'data/repositories/parameter_repository_impl.dart';
import 'domain/use_cases/export_data_use_case.dart';
import 'domain/use_cases/calculate_streak_use_case.dart';
import 'domain/controllers/daily_record_controller.dart';
import 'domain/controllers/parameter_controller.dart';
import 'domain/controllers/data_entry_controller.dart';
import 'domain/controllers/home_controller.dart';
import 'domain/services/preset_parameters_service.dart';

void main() async {
  // Обеспечиваем что Flutter готов к работе
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализируем биндинги
  AppBindings appBindings = AppBindings();
  appBindings.dependencies();
  
  // Инициализируем пресет параметры
  await appBindings.initializePresetParameters();
  
  runApp(const MyApp());
}

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Repositories
    Get.lazyPut<DailyRecordRepository>(() => DailyRecordRepositoryImpl(), fenix: true);
    Get.lazyPut<ParameterRepository>(() => ParameterRepositoryImpl(), fenix: true);

    // Use Cases
    Get.lazyPut<ExportDataUseCase>(
      () => ExportDataUseCase(
        Get.find<DailyRecordRepository>(), 
        Get.find<ParameterRepository>(),
      ),
      fenix: true,
    );
    Get.lazyPut<CalculateStreakUseCase>(
      () => CalculateStreakUseCase(Get.find<DailyRecordRepository>()),
      fenix: true,
    );

    // Controllers
    Get.lazyPut<DailyRecordController>(
      () => DailyRecordController(
        Get.find<DailyRecordRepository>(),
        Get.find<ExportDataUseCase>(),
      ),
      fenix: true,
    );
    Get.lazyPut(() => ParameterController(Get.find<ParameterRepository>()), fenix: true);
    Get.lazyPut(() => DataEntryController(), fenix: true);
    Get.lazyPut<HomeController>(
      () => HomeController(Get.find<CalculateStreakUseCase>()),
      fenix: true,
    );
    
    // Services
    Get.lazyPut<PresetParametersService>(
      () => PresetParametersService(Get.find<ParameterRepository>()),
      fenix: true,
    );
  }
  
  /// Инициализируем пресет параметры при первом запуске
  Future<void> initializePresetParameters() async {
    try {
      print('AppBindings: Initializing preset parameters...');
      PresetParametersService presetService = Get.find<PresetParametersService>();
      await presetService.initializePresetIfNeeded();
      print('AppBindings: Preset parameters initialization completed');
    } catch (e) {
      print('AppBindings: Error initializing preset parameters: $e');
      // Не прерываем запуск приложения из-за ошибки пресетов
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BioLogger - Трекер здоровья',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialBinding: AppBindings(),
      home: const MainNavigationScreen(),
      // Настройка анимаций переходов по умолчанию
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
