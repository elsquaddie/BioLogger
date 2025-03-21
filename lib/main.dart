import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'presentation/screens/home_screen.dart';
import 'data/repositories/daily_record_repository.dart';
import 'data/repositories/daily_record_repository_impl.dart';
import 'data/repositories/parameter_repository.dart';
import 'data/repositories/parameter_repository_impl.dart';
import 'domain/use_cases/export_data_use_case.dart';
import 'domain/controllers/daily_record_controller.dart';
import 'domain/controllers/parameter_controller.dart';
import 'domain/controllers/data_entry_controller.dart';

void main() {
  // Регистрируем зависимости
  // Repositories
  Get.put<DailyRecordRepository>(DailyRecordRepositoryImpl());
  Get.put<ParameterRepository>(ParameterRepositoryImpl());

  // Use Cases
  Get.put(ExportDataUseCase(
    Get.find<DailyRecordRepository>(),
    Get.find<ParameterRepository>(),
  ));

  // Controllers
  Get.put(DailyRecordController(
    Get.find<DailyRecordRepository>(),
    Get.find<ExportDataUseCase>(),
  ));
  Get.put(ParameterController());
  Get.put(DataEntryController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BioLog App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomeScreen(),
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
