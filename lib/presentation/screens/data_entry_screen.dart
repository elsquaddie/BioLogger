import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../domain/controllers/data_entry_controller.dart';
import '../../models/parameter.dart';
import '../theme/app_theme.dart';
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
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    });
  }

  void _loadCurrentParameterData() {
    final currentParameter = _dataEntryController.currentParameter;
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
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Obx(() {
          final selectedDate = _dataEntryController.selectedDate.value;
          final dateText = DateFormat('dd.MM.yyyy').format(selectedDate);
          return Text('Данные за $dateText');
        }),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Если мы в режиме списка, возвращаемся к режиму редактирования
            if (_isListViewMode.value) {
              _isListViewMode.value = false;
              _loadCurrentParameterData();
            } else {
              // Если мы в режиме редактирования, возвращаемся на главную
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
              _saveCurrentParameter(); // Сохраняем текущий параметр
              _dataEntryController.currentParameterIndex.value = index;
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: theme.colorScheme.primary),
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
    );
  }

  /// Строит кнопки навигации
  Widget _buildNavigationButtons(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
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
            child: ElevatedButton.icon(
              onPressed: _nextParameter,
              icon: Icon(_dataEntryController.isLastParameter ? Icons.save : Icons.arrow_forward),
              label: Text(_dataEntryController.isLastParameter ? 'Сохранить' : 'Далее'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
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
          displayValue = '$value/10';
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
        // Находим правильный индекс параметра в списке parametersForEntry
        final correctIndex = _dataEntryController.parametersForEntry.indexWhere((p) => p.id == parameter.id);
        if (correctIndex != -1) {
          _isListViewMode.value = false;
          _dataEntryController.setInitialViewMode('edit');
          _dataEntryController.currentParameterIndex.value = correctIndex;
          
          // Принудительно переводим PageController на правильную страницу
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageController.hasClients) {
              _pageController.animateToPage(
                correctIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
            _loadCurrentParameterData();
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          children: [
            // Иконка параметра - точная копия из values.html
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F3F1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                ParameterIcons.getIcon(parameter),
                size: 24,
                color: const Color(0xFF141613),
              ),
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
    );
  }

  /// Строит страницу для конкретного параметра
  Widget _buildParameterPage(Parameter parameter, BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Большая иконка и информация о параметре
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F3F1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    ParameterIcons.getIcon(parameter),
                    size: 40,
                    color: const Color(0xFF141613),
                  ),
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
          
          const Spacer(),
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
                      Text('1', style: theme.textTheme.bodyMedium),
                      Text('10', style: theme.textTheme.bodyMedium),
                    ],
                  ),
                  Slider(
                    value: _ratingValue,
                    min: 1.0,
                    max: 10.0,
                    divisions: 9,
                    label: _ratingValue.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        _ratingValue = value;
                      });
                      final parameterId = parameter.id.toString();
                      _dataEntryController.updateEnteredValue(parameterId, value.round().toString());
                    },
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