import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../domain/controllers/data_entry_controller.dart';
import '../../models/parameter.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components/index.dart';
import 'main_navigation_screen.dart';
import '../../utils/parameter_icons.dart';

class DataEntryScreen extends StatefulWidget {
  const DataEntryScreen({Key? key}) : super(key: key);

  @override
  State<DataEntryScreen> createState() => _DataEntryScreenState();
}

class _DataEntryScreenState extends State<DataEntryScreen> {
  final DataEntryController _dataEntryController = Get.find<DataEntryController>();
  late PageController _pageController;
  late TextEditingController _valueController;
  late TextEditingController _commentController;
  final FocusNode _valueFocusNode = FocusNode();
  double _ratingValue = 1.0;
  bool _yesNoValue = false;
  final RxBool _isListViewMode = false.obs;
  bool _isProgrammaticPageChange = false; // Флаг для игнорирования программных изменений страницы
  int? _targetPageIndex; // Целевой индекс страницы при программной навигации

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _valueController = TextEditingController();
    _commentController = TextEditingController();
    
    // Устанавливаем начальный режим на основе initialViewMode из контроллера
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isListViewMode.value = _dataEntryController.initialViewMode.value == 'list';
      if (!_isListViewMode.value) {
        _loadCurrentParameterData();
      }
    });
    
    // Слушаем изменения initialViewMode для переключения режимов
    ever(_dataEntryController.initialViewMode, (mode) {
      _isListViewMode.value = mode == 'list';
      if (!_isListViewMode.value) {
        _loadCurrentParameterData();
      }
    });
    
    // Слушаем изменения текущего параметра
    ever(_dataEntryController.currentParameterIndex, (index) {
      if (!_isListViewMode.value) {
        _loadCurrentParameterData();
        // Анимируем только если PageController привязан к PageView
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients) {
            _isProgrammaticPageChange = true; // Устанавливаем флаг перед программным изменением
            _targetPageIndex = index; // Сохраняем целевой индекс
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ).then((_) {
              // Сбрасываем флаг после завершения анимации
              print("DataEntryScreen: Animation completed (from ever listener), resetting programmatic flag (backup)");
              _isProgrammaticPageChange = false;
              _targetPageIndex = null;
            });
          }
        });
      }
    });
  }

  void _loadCurrentParameterData() {
    final currentParameter = _dataEntryController.currentParameter;
    final currentIndex = _dataEntryController.currentParameterIndex.value;
    
    print("DataEntryScreen: _loadCurrentParameterData called");
    print("DataEntryScreen: currentParameterIndex = $currentIndex");
    print("DataEntryScreen: currentParameter = ${currentParameter?.name} (ID: ${currentParameter?.id})");
    
    if (currentParameter != null) {
      final parameterId = currentParameter.id.toString();
      final value = _dataEntryController.enteredValues[parameterId]?.toString() ?? '';
      final comment = _dataEntryController.enteredComments[parameterId] ?? '';
      
      setState(() {
        _valueController.text = value;
        _commentController.text = comment;
        
        // Загружаем значения для специфичных типов
        if (currentParameter.dataType == 'Rating') {
          _ratingValue = double.tryParse(value) ?? 1.0;
        } else if (currentParameter.dataType == 'YesNo') {
          _yesNoValue = value.toLowerCase() == 'да' || value.toLowerCase() == 'yes' || value == 'true';
        }
      });
      
      // Автофокус для Number/Text полей или убираем фокус для остальных
      if (currentParameter.dataType == 'Number' || currentParameter.dataType == 'Text') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _valueFocusNode.requestFocus();
        });
      } else if (currentParameter.dataType == 'Rating' || currentParameter.dataType == 'YesNo') {
        // Убираем клавиатуру для типов, которые не нуждаются в текстовом вводе
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).unfocus();
        });
      }
    }
  }
  
  void _saveCurrentParameter() {
    final currentParameter = _dataEntryController.currentParameter;
    if (currentParameter != null) {
      final parameterId = currentParameter.id.toString();
      
      String value = '';
      switch (currentParameter.dataType) {
        case 'Number':
        case 'Text':
          value = _valueController.text;
          break;
        case 'Rating':
          value = _ratingValue.round().toString();
          break;
        case 'YesNo':
          value = _yesNoValue ? 'Да' : 'Нет';
          break;
      }
      
      _dataEntryController.updateEnteredValue(parameterId, value);
      _dataEntryController.updateEnteredComment(parameterId, _commentController.text);
    }
  }
  
  void _nextParameter() {
    _saveCurrentParameter();
    
    if (_dataEntryController.isLastParameter) {
      // Сохраняем все данные
      _dataEntryController.saveDailyRecord();
    } else {
      // Переходим к следующему параметру
      _dataEntryController.nextParameter();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _valueController.dispose();
    _commentController.dispose();
    _valueFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Obx(() {
          final selectedDate = _dataEntryController.selectedDate.value;
          final dateText = DateFormat('dd.MM.yyyy').format(selectedDate);
          return Text('Данные за $dateText');
        }),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.brandGreen,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Если мы в режиме редактирования параметра, переходим к списку параметров
            if (!_isListViewMode.value) {
              _isListViewMode.value = true;
            } else {
              // Если мы в режиме списка параметров, возвращаемся на главную
              try {
                final navigationController = Get.find<NavigationController>();
                navigationController.goToHome();
              } catch (e) {
                Navigator.of(context).pop();
              }
            }
          },
        ),
        actions: [
          Obx(() {
            // Не показываем иконку переключения режима когда активен список
            if (_isListViewMode.value) return const SizedBox.shrink();
            
            return IconButton(
              icon: const Icon(Icons.list),
              tooltip: 'Быстрый просмотр',
              onPressed: () {
                _isListViewMode.value = true;
              },
            );
          }),
          Obx(() {
            final totalParams = _dataEntryController.parametersForEntry.length;
            final currentIndex = _dataEntryController.currentParameterIndex.value;
            if (totalParams == 0 || _isListViewMode.value) return const SizedBox.shrink();
            
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '${currentIndex + 1} / $totalParams',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        final parameters = _dataEntryController.parametersForEntry;
        final currentParameter = _dataEntryController.currentParameter;
        
        if (parameters.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'Нет активных параметров',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Включите параметры в настройках',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }
        
        return Obx(() => _isListViewMode.value 
          ? _buildListView(parameters, context, theme)
          : _buildPageView(parameters, currentParameter, context, theme)
        );
      }),
    );
  }

  /// Строит режим редактирования с PageView
  Widget _buildPageView(List<Parameter> parameters, Parameter? currentParameter, BuildContext context, ThemeData theme) {
    if (currentParameter == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return Column(
      children: [
        // Прогресс бар
        Container(
          margin: const EdgeInsets.all(16),
          child: LinearProgressIndicator(
            value: ((_dataEntryController.currentParameterIndex.value + 1) / parameters.length),
            backgroundColor: theme.colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            minHeight: 6,
          ),
        ),
        
        // Выбор даты
        _buildDatePicker(theme),
        
        // PageView с параметрами
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: parameters.length,
            onPageChanged: (index) {
              print("DataEntryScreen: PageView.onPageChanged called with index $index, isProgrammatic: $_isProgrammaticPageChange, targetIndex: $_targetPageIndex");
              
              // Игнорируем программные изменения страницы
              if (_isProgrammaticPageChange) {
                print("DataEntryScreen: Ignoring programmatic page change");
                
                // Если достигли целевого индекса, сбрасываем флаг
                if (_targetPageIndex != null && index == _targetPageIndex) {
                  print("DataEntryScreen: Reached target page index $_targetPageIndex, resetting flags");
                  _isProgrammaticPageChange = false;
                  _targetPageIndex = null;
                }
                return;
              }
              
              // Проверяем, соответствует ли index текущему индексу контроллера
              final currentControllerIndex = _dataEntryController.currentParameterIndex.value;
              if (index == currentControllerIndex) {
                print("DataEntryScreen: PageView index matches controller index, ignoring");
                return;
              }
              
              _saveCurrentParameter(); // Сохраняем текущий параметр
              _dataEntryController.setCurrentParameterIndex(index, "PageView.onPageChanged by user swipe");
            },
            itemBuilder: (context, index) {
              final parameter = parameters[index];
              return _buildParameterPage(parameter, context, theme);
            },
          ),
        ),
        
        // Кнопки навигации
        _buildNavigationButtons(theme),
      ],
    );
  }

  /// Строит быстрый просмотр с ListView
  Widget _buildListView(List<Parameter> parameters, BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Список параметров
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
            itemCount: parameters.length,
            itemBuilder: (context, index) {
              final parameter = parameters[index];
              return _buildParameterListItem(parameter, index, theme);
            },
          ),
        ),
      ],
    );
  }
  
  /// Форматирует дату для заголовка списка в стиле "Monday, July 15"
  String _formatDateForList(DateTime date) {
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    return '$weekday, $month ${date.day}';
  }

  /// Строит виджет выбора даты
  Widget _buildDatePicker(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            TintedIconBox(
              icon: Icons.calendar_today,
              size: 40,
              iconSize: 20,
            ),
            const SizedBox(width: 12),
            Text('Дата:', style: theme.textTheme.titleMedium),
            const Spacer(),
            TextButton.icon(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _dataEntryController.selectedDate.value,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  _dataEntryController.selectDate(pickedDate);
                }
              },
              icon: const Icon(Icons.edit),
              label: Text(
                DateFormat('dd.MM.yyyy').format(_dataEntryController.selectedDate.value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Строит кнопки навигации
  Widget _buildNavigationButtons(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Obx(() => Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _dataEntryController.currentParameterIndex.value > 0
                  ? () {
                      _saveCurrentParameter();
                      _dataEntryController.previousParameter();
                    }
                  : null,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Назад'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: PrimaryButton(
              text: _dataEntryController.isLastParameter ? 'Сохранить' : 'Далее',
              icon: _dataEntryController.isLastParameter ? Icons.save : Icons.arrow_forward,
              onPressed: _nextParameter,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      )),
    );
  }

  /// Строит элемент списка параметра (компактный вид)
  Widget _buildParameterListItem(Parameter parameter, int index, ThemeData theme) {
    final parameterId = parameter.id.toString();
    final value = _dataEntryController.enteredValues[parameterId]?.toString() ?? '';
    final comment = _dataEntryController.enteredComments[parameterId] ?? '';
    
    String displayValue = '';
    if (value.isNotEmpty) {
      switch (parameter.dataType) {
        case 'Number':
          displayValue = parameter.unit != null ? '$value ${parameter.unit}' : value;
          break;
        case 'Text':
          // Для текстовых полей показываем превью с отточием
          displayValue = value.length > 30 ? '${value.substring(0, 30)}...' : value;
          break;
        case 'Rating':
          // Получаем максимальное значение из scaleOptions
          int maxValue = 10; // Дефолт
          if (parameter.scaleOptions != null) {
            for (String option in parameter.scaleOptions!) {
              if (option.startsWith('max:')) {
                maxValue = int.tryParse(option.substring(4)) ?? 10;
                break;
              }
            }
          }
          displayValue = '$value/$maxValue';
          break;
        case 'YesNo':
          displayValue = value;
          break;
        default:
          displayValue = value;
      }
      
      // Добавляем комментарий, но тоже с ограничением
      if (comment.isNotEmpty) {
        final shortComment = comment.length > 20 ? '${comment.substring(0, 20)}...' : comment;
        
        if (parameter.dataType == 'Text') {
          // Для текстовых полей показываем как "Notes: комментарий"
          displayValue = 'Notes: $shortComment';
        } else {
          // Для остальных типов добавляем через точку
          displayValue += ' • $shortComment';
        }
      }
    } else {
      displayValue = 'Не заполнено';
    }
    
    return InkWell(
      onTap: () {
        // КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ: Используем новый метод для установки параметра по ID
        print("DataEntryScreen: User tapped parameter '${parameter.name}' with ID ${parameter.id}");
        
        // Устанавливаем параметр для навигации по ID
        _dataEntryController.setParameterForNavigation(parameter.id!);
        _dataEntryController.setInitialViewMode('edit');
        _isListViewMode.value = false;
        
        // Анимируем к правильной странице после установки индекса
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final currentIndex = _dataEntryController.currentParameterIndex.value;
          print("DataEntryScreen: Animating to page index $currentIndex");
          
          if (_pageController.hasClients && currentIndex >= 0) {
            _isProgrammaticPageChange = true; // Устанавливаем флаг перед программным изменением
            _targetPageIndex = currentIndex; // Сохраняем целевой индекс
            _pageController.animateToPage(
              currentIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ).then((_) {
              // Дополнительная защита - сбрасываем флаги после завершения анимации
              print("DataEntryScreen: Animation completed, resetting programmatic flag (backup)");
              _isProgrammaticPageChange = false;
              _targetPageIndex = null;
            });
          }
          _loadCurrentParameterData();
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: AppCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Иконка параметра в новом стиле с кастомными цветами
              SmallTintedIconBox(
                icon: ParameterIcons.getIcon(parameter),
                size: 48,
                iconSize: 24,
                backgroundColor: ParameterIcons.getIconBackgroundColor(parameter, theme.colorScheme),
                iconColor: ParameterIcons.getIconColor(parameter, theme.colorScheme),
              ),
              const SizedBox(width: 16),
              
              // Название и значение
              Expanded(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    parameter.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF141613),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayValue,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: value.isEmpty ? Colors.grey.shade500 : const Color(0xFF757C6E),
                      fontWeight: FontWeight.normal,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Строит страницу для конкретного параметра
  Widget _buildParameterPage(Parameter parameter, BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Большая иконка и информация о параметре
          AppCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                TintedIconBox(
                  icon: ParameterIcons.getIcon(parameter),
                  size: 80,
                  iconSize: 40,
                  backgroundColor: ParameterIcons.getIconBackgroundColor(parameter, theme.colorScheme),
                  iconColor: ParameterIcons.getIconColor(parameter, theme.colorScheme),
                ),
                const SizedBox(height: 16),
                Text(
                  parameter.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (parameter.unit != null && parameter.unit!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Единицы: ${parameter.unit}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Поле ввода в зависимости от типа
          _buildInputField(parameter, theme),
          
          const SizedBox(height: 24),
          
          // Поле комментария
          TextFormField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: 'Комментарий (необязательно)',
              hintText: 'Добавьте заметку',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            minLines: 1,
            onChanged: (value) {
              final parameterId = parameter.id.toString();
              _dataEntryController.updateEnteredComment(parameterId, value);
            },
          ),
        ],
      ),
    );
  }

  /// Строит поле ввода в зависимости от типа параметра
  Widget _buildInputField(Parameter parameter, ThemeData theme) {
    switch (parameter.dataType) {
      case 'Number':
        return TextFormField(
          controller: _valueController,
          focusNode: _valueFocusNode,
          decoration: InputDecoration(
            labelText: 'Введите значение',
            hintText: parameter.unit != null 
                ? 'Например: 10 ${parameter.unit}'
                : 'Введите число',
            border: const OutlineInputBorder(),
            prefixIcon: Icon(ParameterIcons.getIcon(parameter)),
          ),
          keyboardType: TextInputType.number,
          maxLines: 3,
          minLines: 1,
          onChanged: (value) {
            final parameterId = parameter.id.toString();
            _dataEntryController.updateEnteredValue(parameterId, value);
          },
        );

      case 'Text':
        return TextFormField(
          controller: _valueController,
          focusNode: _valueFocusNode,
          decoration: InputDecoration(
            labelText: 'Введите текст',
            hintText: 'Введите текстовое значение',
            border: const OutlineInputBorder(),
            prefixIcon: Icon(ParameterIcons.getIcon(parameter)),
          ),
          maxLines: 5,
          minLines: 1,
          onChanged: (value) {
            final parameterId = parameter.id.toString();
            _dataEntryController.updateEnteredValue(parameterId, value);
          },
        );

      case 'Rating':
        // Парсим настройки шкалы из scaleOptions
        int minValue = 1;
        int maxValue = 10;
        String leftLabel = 'Плохо';
        String rightLabel = 'Отлично';
        
        if (parameter.scaleOptions != null) {
          print('DataEntryScreen: Parsing scaleOptions for ${parameter.name}: ${parameter.scaleOptions}');
          for (String option in parameter.scaleOptions!) {
            if (option.startsWith('min:')) {
              final newMin = int.tryParse(option.substring(4)) ?? 1;
              minValue = newMin;
              print('DataEntryScreen: Found min value: $newMin');
            } else if (option.startsWith('max:')) {
              final newMax = int.tryParse(option.substring(4)) ?? 10;
              maxValue = newMax;
              print('DataEntryScreen: Found max value: $newMax');
            } else if (option.startsWith('left:')) {
              leftLabel = option.substring(5);
              print('DataEntryScreen: Found left label: $leftLabel');
            } else if (option.startsWith('right:')) {
              rightLabel = option.substring(6);
              print('DataEntryScreen: Found right label: $rightLabel');
            }
            // Игнорируем другие опции (например, color:)
          }
        }
        
        // Совместимость со старыми пресет параметрами
        if (parameter.isPreset && parameter.scaleOptions != null && parameter.scaleOptions!.isNotEmpty) {
          // Старые пресет параметры используют scaleOptions как массив значений ["1","2","3",...]
          final firstOption = parameter.scaleOptions!.first;
          if (!firstOption.contains(':')) {
            // Это старый формат - используем длину массива как максимальное значение
            maxValue = parameter.scaleOptions!.length;
            leftLabel = 'Плохо';
            rightLabel = 'Отлично';
          }
        }
        
        print('DataEntryScreen: Rating scale config for ${parameter.name}: min=$minValue, max=$maxValue, left="$leftLabel", right="$rightLabel"');
        
        // Убеждаемся что _ratingValue в допустимых пределах
        if (_ratingValue < minValue) _ratingValue = minValue.toDouble();
        if (_ratingValue > maxValue) _ratingValue = maxValue.toDouble();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Оценка: ${_ratingValue.round()}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          leftLabel,
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          rightLabel,
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _ratingValue,
                    min: minValue.toDouble(),
                    max: maxValue.toDouble(),
                    divisions: maxValue - minValue,
                    label: _ratingValue.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        _ratingValue = value;
                      });
                      final parameterId = parameter.id.toString();
                      _dataEntryController.updateEnteredValue(parameterId, value.round().toString());
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$minValue', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      Text('$maxValue', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );

      case 'YesNo':
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                parameter.name,
                style: theme.textTheme.titleMedium,
              ),
              Switch(
                value: _yesNoValue,
                onChanged: (value) {
                  setState(() {
                    _yesNoValue = value;
                  });
                  final parameterId = parameter.id.toString();
                  _dataEntryController.updateEnteredValue(parameterId, value ? 'Да' : 'Нет');
                },
              ),
            ],
          ),
        );

      default:
        return TextFormField(
          controller: _valueController,
          focusNode: _valueFocusNode,
          decoration: const InputDecoration(
            labelText: 'Значение',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            final parameterId = parameter.id.toString();
            _dataEntryController.updateEnteredValue(parameterId, value);
          },
        );
    }
  }
  
  TextInputType _getKeyboardType(String dataType) {
    switch (dataType.toLowerCase()) {
      case 'number':
      case 'rating':
        return TextInputType.number;
      case 'text':
        return TextInputType.text;
      default:
        return TextInputType.text;
    }
  }
}