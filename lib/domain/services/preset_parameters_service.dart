import '../../models/parameter.dart';
import '../../data/repositories/parameter_repository.dart';
import '../../data/repositories/parameter_repository_impl.dart';

class PresetParametersService {
  final ParameterRepository _parameterRepository;
  
  PresetParametersService(this._parameterRepository);
  
  /// Возвращает список всех дефолтных пресет параметров
  static List<Parameter> getDefaultParameters() {
    // Используем фиксированную дату, так как поле created_at может отсутствовать в БД
    final now = DateTime(2025, 1, 1);
    
    return [
      Parameter(
        name: 'Сон',
        dataType: 'Number',
        unit: 'часы',
        isPreset: true,
        isEnabled: true,
        sortOrder: 1,
        iconName: 'bedtime',
        createdAt: now,
      ),
      Parameter(
        name: 'БАДы',
        dataType: 'Text',
        isPreset: true,
        isEnabled: true,
        sortOrder: 2,
        iconName: 'medication',
        createdAt: now,
      ),
      Parameter(
        name: 'Оценка качества работы',
        dataType: 'Rating',
        unit: '1-10',
        scaleOptions: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'],
        isPreset: true,
        isEnabled: true,
        sortOrder: 3,
        iconName: 'work',
        createdAt: now,
      ),
      Parameter(
        name: 'Тренировка',
        dataType: 'Number',
        unit: 'минуты',
        isPreset: true,
        isEnabled: true,
        sortOrder: 4,
        iconName: 'fitness_center',
        createdAt: now,
      ),
      Parameter(
        name: 'Количество шагов',
        dataType: 'Number',
        isPreset: true,
        isEnabled: true,
        sortOrder: 5,
        iconName: 'directions_walk',
        createdAt: now,
      ),
      Parameter(
        name: 'Оценка социальности',
        dataType: 'Rating',
        unit: '1-10',
        scaleOptions: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'],
        isPreset: true,
        isEnabled: true,
        sortOrder: 6,
        iconName: 'groups',
        createdAt: now,
      ),
      Parameter(
        name: 'Оценка настроения',
        dataType: 'Rating',
        unit: '1-10',
        scaleOptions: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'],
        isPreset: true,
        isEnabled: true,
        sortOrder: 7,
        iconName: 'sentiment_satisfied',
        createdAt: now,
      ),
      Parameter(
        name: 'Оценка своей привлекательности',
        dataType: 'Rating',
        unit: '1-10',
        scaleOptions: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'],
        isPreset: true,
        isEnabled: true,
        sortOrder: 8,
        iconName: 'favorite',
        createdAt: now,
      ),
      Parameter(
        name: 'Оценка самореализации',
        dataType: 'Rating',
        unit: '1-10',
        scaleOptions: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'],
        isPreset: true,
        isEnabled: true,
        sortOrder: 9,
        iconName: 'star',
        createdAt: now,
      ),
      Parameter(
        name: 'Оценка качества питания',
        dataType: 'Rating',
        unit: '1-10',
        scaleOptions: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'],
        isPreset: true,
        isEnabled: true,
        sortOrder: 10,
        iconName: 'restaurant',
        createdAt: now,
      ),
      Parameter(
        name: 'Оценка текущих финансов',
        dataType: 'Rating',
        unit: '1-10',
        scaleOptions: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'],
        isPreset: true,
        isEnabled: true,
        sortOrder: 11,
        iconName: 'attach_money',
        createdAt: now,
      ),
      Parameter(
        name: 'Оценка социальной полезности',
        dataType: 'Rating',
        unit: '1-10',
        scaleOptions: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'],
        isPreset: true,
        isEnabled: true,
        sortOrder: 12,
        iconName: 'public',
        createdAt: now,
      ),
      Parameter(
        name: 'Оценка прошедшего дня',
        dataType: 'Rating',
        unit: '1-10',
        scaleOptions: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'],
        isPreset: true,
        isEnabled: true,
        sortOrder: 13,
        iconName: 'thumb_up',
        createdAt: now,
      ),
      Parameter(
        name: 'Почему такая оценка',
        dataType: 'Text',
        isPreset: true,
        isEnabled: true,
        sortOrder: 14,
        iconName: 'edit_note',
        createdAt: now,
      ),
      Parameter(
        name: 'Воспоминания обо дне',
        dataType: 'Text',
        isPreset: true,
        isEnabled: true,
        sortOrder: 15,
        iconName: 'menu_book',
        createdAt: now,
      ),
    ];
  }
  
  /// Проверяет наличие пресет параметров и создает их при необходимости
  Future<void> initializePresetIfNeeded() async {
    try {
      print('PresetParametersService: Checking if preset parameters exist...');
      
      // Проверяем, есть ли уже пресет параметры
      bool hasPresets = await _parameterRepository.hasPresetParameters();
      
      if (hasPresets) {
        print('PresetParametersService: Preset parameters already exist, skipping initialization');
        return;
      }
      
      print('PresetParametersService: No preset parameters found, creating defaults...');
      
      // Получаем дефолтные параметры
      List<Parameter> defaultParameters = getDefaultParameters();
      
      // Создаем пресеты в БД
      await _parameterRepository.insertPresetParameters(defaultParameters);
      
      print('PresetParametersService: Successfully created ${defaultParameters.length} preset parameters');
      
      // Логируем созданные параметры
      for (Parameter param in defaultParameters) {
        print('PresetParametersService: Created preset - ${param.name} (${param.dataType}, sortOrder: ${param.sortOrder})');
      }
      
    } catch (e) {
      print('PresetParametersService: Error initializing preset parameters: $e');
      rethrow;
    }
  }
  
  /// Сбрасывает все пресет параметры (для отладки/тестирования)
  Future<void> resetPresetParameters() async {
    try {
      print('PresetParametersService: Resetting preset parameters...');
      
      // Получаем все пресет параметры
      List<Parameter> presetParameters = await _parameterRepository.getPresetParameters();
      
      // Удаляем их (если это возможно, иначе просто отключаем)
      for (Parameter preset in presetParameters) {
        if (preset.id != null) {
          try {
            await _parameterRepository.deleteParameter(preset.id!);
          } catch (e) {
            // Если удаление не удалось, просто отключаем
            await _parameterRepository.toggleParameterEnabled(preset.id!, false);
          }
        }
      }
      
      // Создаем заново
      await initializePresetIfNeeded();
      
      print('PresetParametersService: Preset parameters reset completed');
      
    } catch (e) {
      print('PresetParametersService: Error resetting preset parameters: $e');
      rethrow;
    }
  }
  
  /// Возвращает количество созданных пресет параметров
  Future<int> getPresetParametersCount() async {
    try {
      List<Parameter> presets = await _parameterRepository.getPresetParameters();
      return presets.length;
    } catch (e) {
      print('PresetParametersService: Error getting preset count: $e');
      return 0;
    }
  }
  
  /// Включает/выключает пресет параметр по имени
  Future<bool> togglePresetParameter(String parameterName, bool isEnabled) async {
    try {
      List<Parameter> presets = await _parameterRepository.getPresetParameters();
      Parameter? targetParam = presets.where((p) => p.name == parameterName).firstOrNull;
      
      if (targetParam?.id != null) {
        await _parameterRepository.toggleParameterEnabled(targetParam!.id!, isEnabled);
        print('PresetParametersService: Toggled $parameterName to ${isEnabled ? "enabled" : "disabled"}');
        return true;
      }
      
      print('PresetParametersService: Parameter $parameterName not found');
      return false;
    } catch (e) {
      print('PresetParametersService: Error toggling parameter $parameterName: $e');
      return false;
    }
  }
}