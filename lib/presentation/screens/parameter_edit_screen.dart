import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/parameter.dart';
import '../../domain/controllers/parameter_controller.dart';
import '../widgets/ui_components/index.dart';
import '../theme/app_theme.dart';
import 'icon_picker_screen.dart';
import '../../utils/parameter_icons.dart';

class ParameterEditScreen extends StatefulWidget {
  final Parameter parameter;

  const ParameterEditScreen({Key? key, required this.parameter}) : super(key: key);

  @override
  State<ParameterEditScreen> createState() => _ParameterEditScreenState();
}

class _ParameterEditScreenState extends State<ParameterEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _parameterController = Get.find<ParameterController>();
  final _nameController = TextEditingController();
  final _unitController = TextEditingController();
  final _leftEdgeController = TextEditingController();
  final _rightEdgeController = TextEditingController();
  
  // Состояние формы
  int _currentStep = 0; // 0 = Шаг 1, 1 = Шаг 2
  String _parameterName = '';
  Color _selectedColor = AppTheme.brandGreen;
  IconData _selectedIcon = Icons.directions_walk;
  String _dataType = 'Number'; // Number, Rating, Text
  String _unit = '';
  String _leftEdge = 'Плохо';
  String _rightEdge = 'Отлично';
  double _ratingValue = 5.0;
  int _minRating = 1;
  int _maxRating = 10;
  
  // Доступные цвета
  final List<Color> _availableColors = [
    AppTheme.brandGreen,      // #88A874
    const Color(0xFF3b82f6), // синий
    const Color(0xFFf59e0b), // оранжевый  
    const Color(0xFFef4444), // красный
    const Color(0xFF8b5cf6), // фиолетовый
    const Color(0xFF10b981), // бирюзовый
    const Color(0xFFf97316), // апельсиновый
  ];
  
  // Быстрые иконки
  final List<IconData> _quickIcons = [
    Icons.sentiment_neutral,
    Icons.favorite,
    Icons.grade,
    Icons.restaurant,
    Icons.attach_money,
    Icons.public,
  ];

  @override
  void initState() {
    super.initState();
    
    print("ParameterEditScreen: Editing parameter '${widget.parameter.name}' with ID ${widget.parameter.id}");
    
    // Инициализируем значения из существующего параметра
    _parameterName = widget.parameter.name;
    _nameController.text = widget.parameter.name;
    _dataType = widget.parameter.dataType;
    _unit = widget.parameter.unit ?? '';
    _unitController.text = _unit;
    
    // Парсим иконку
    _selectedIcon = ParameterIcons.getIcon(widget.parameter);
    
    // Парсим цвет
    final customColor = ParameterIcons.getCustomColor(widget.parameter);
    if (customColor != null) {
      _selectedColor = customColor;
    }
    
    // Парсим настройки рейтинга если есть
    if (widget.parameter.dataType == 'Rating' && widget.parameter.scaleOptions != null) {
      for (String option in widget.parameter.scaleOptions!) {
        if (option.startsWith('min:')) {
          _minRating = int.tryParse(option.substring(4)) ?? 1;
        } else if (option.startsWith('max:')) {
          _maxRating = int.tryParse(option.substring(4)) ?? 10;
        } else if (option.startsWith('left:')) {
          _leftEdge = option.substring(5);
        } else if (option.startsWith('right:')) {
          _rightEdge = option.substring(6);
        }
      }
    }
    
    _leftEdgeController.text = _leftEdge;
    _rightEdgeController.text = _rightEdge;
    _ratingValue = ((_minRating + _maxRating) / 2).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Редактировать: ${widget.parameter.name}'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.brandGreen,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                // Шаг 1
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _currentStep >= 0 ? Colors.white.withOpacity(0.9) : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '1',
                          style: TextStyle(
                            color: _currentStep >= 0 ? AppTheme.brandGreen : Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Базовые',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Text(
                  '—',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                // Шаг 2
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _currentStep >= 1 ? Colors.white.withOpacity(0.9) : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '2',
                          style: TextStyle(
                            color: _currentStep >= 1 ? AppTheme.brandGreen : Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Тип',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _currentStep == 0 ? _buildStep1() : _buildStep2(),
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  /// Строит первый шаг - базовые настройки
  Widget _buildStep1() {
    final theme = Theme.of(context);
    
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Заголовок шага
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Базовые настройки',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Text(
                'Шаг 1 из 2',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Название
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Название',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Иконка аватар
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Icon(
                      _selectedIcon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Поле ввода
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Например, Вода',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _parameterName = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Коротко и понятно — так параметр легче найти в списке.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Цвет
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Цвет',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _availableColors.map((color) {
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(14),
                        border: isSelected 
                          ? Border.all(color: color, width: 3)
                          : Border.all(color: Colors.black.withOpacity(0.1)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Иконка
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Иконка',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF374151),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final selectedIcon = await Navigator.of(context).push<IconData>(
                        MaterialPageRoute(
                          builder: (context) => IconPickerScreen(
                            selectedIcon: _selectedIcon,
                            selectedColor: _selectedColor,
                          ),
                        ),
                      );
                      
                      if (selectedIcon != null) {
                        setState(() {
                          _selectedIcon = selectedIcon;
                        });
                      }
                    },
                    child: const Text('Все иконки'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Быстрые иконки
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._quickIcons.map((icon) {
                    final isSelected = _selectedIcon == icon;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIcon = icon;
                        });
                      },
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isSelected ? _selectedColor.withOpacity(0.2) : AppTheme.tintGreen,
                          borderRadius: BorderRadius.circular(26),
                          border: isSelected 
                            ? Border.all(color: _selectedColor, width: 2)
                            : null,
                        ),
                        child: Icon(
                          icon,
                          color: isSelected ? _selectedColor : AppTheme.brandGreen,
                          size: 24,
                        ),
                      ),
                    );
                  }),
                  // Кнопка "+" для полной библиотеки
                  GestureDetector(
                    onTap: () async {
                      final selectedIcon = await Navigator.of(context).push<IconData>(
                        MaterialPageRoute(
                          builder: (context) => IconPickerScreen(
                            selectedIcon: _selectedIcon,
                            selectedColor: _selectedColor,
                          ),
                        ),
                      );
                      
                      if (selectedIcon != null) {
                        setState(() {
                          _selectedIcon = selectedIcon;
                        });
                      }
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: const Color(0xFFD1D5DB), style: BorderStyle.solid),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Color(0xFF6B7280),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Превью карточки
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Предварительный просмотр',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _selectedColor,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        _selectedIcon,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _parameterName.isEmpty ? widget.parameter.name : _parameterName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Последнее значение: 5',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF9CA3AF),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Строит второй шаг - тип и формат данных (аналогично parameter_create_screen)
  Widget _buildStep2() {
    final theme = Theme.of(context);
    
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Заголовок шага
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Тип и формат данных',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Text(
                'Шаг 2 из 2',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Выбор типа данных
          Row(
            children: [
              Expanded(child: _buildTypeButton('Number', 'Число')),
              const SizedBox(width: 8),
              Expanded(child: _buildTypeButton('Rating', 'Шкала')),
              const SizedBox(width: 8),
              Expanded(child: _buildTypeButton('Text', 'Текст')),
            ],
          ),
          const SizedBox(height: 16),
          
          // Описание выбранного типа
          if (_dataType == 'Rating')
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Оценка по шкале — удобно для настроения, боли, стресса.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          
          // Контент в зависимости от типа
          if (_dataType == 'Number') _buildNumberTypeContent(theme),
          if (_dataType == 'Rating') _buildRatingTypeContent(theme),
          if (_dataType == 'Text') _buildTextTypeContent(theme),
          
          const SizedBox(height: 24),
          
          // Превью карточки (обновленное)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Предварительный просмотр',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _selectedColor,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        _selectedIcon,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _parameterName.isEmpty ? widget.parameter.name : _parameterName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _getPreviewSubtitle(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF9CA3AF),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Копируем методы из parameter_create_screen для единообразия
  Widget _buildTypeButton(String type, String label) {
    final theme = Theme.of(context);
    final isSelected = _dataType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _dataType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? _selectedColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _selectedColor : const Color(0xFFD1D5DB),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected ? Colors.white : const Color(0xFF374151),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  
  Widget _buildNumberTypeContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Единица измерения (необязательно)',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _unitController,
          decoration: const InputDecoration(
            hintText: 'Например: кг, л, часов',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _unit = value;
            });
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Единица измерения помогает видеть, в чём измеряется параметр.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
  
  Widget _buildRatingTypeContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Поля для левого и правого края
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Левый край',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _leftEdgeController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _leftEdge = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Правый край',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _rightEdgeController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _rightEdge = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Минимальное и максимальное значения
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Минимальное значение',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _minRating.toString(),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final newMin = int.tryParse(value);
                      if (newMin != null && newMin >= 1 && newMin <= 50) {
                        setState(() {
                          _minRating = newMin;
                          if (_maxRating <= _minRating) {
                            _maxRating = _minRating + 1;
                          }
                          if (_ratingValue < _minRating) {
                            _ratingValue = _minRating.toDouble();
                          }
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Максимальное значение',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _maxRating.toString(),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final newMax = int.tryParse(value);
                      if (newMax != null && newMax >= 2 && newMax <= 100 && newMax > _minRating) {
                        setState(() {
                          _maxRating = newMax;
                          if (_ratingValue > _maxRating) {
                            _ratingValue = _maxRating.toDouble();
                          }
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Превью слайдера
        Text(
          'Предварительный просмотр шкалы',
          style: theme.textTheme.bodySmall?.copyWith(
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Как будет выглядеть в приложении:',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 12),
              // Метки слева и справа
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _leftEdge,
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _rightEdge,
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              // Слайдер
              Row(
                children: [
                  Text('$_minRating', style: theme.textTheme.bodySmall),
                  Expanded(
                    child: Slider(
                      value: _ratingValue,
                      min: _minRating.toDouble(),
                      max: _maxRating.toDouble(),
                      divisions: _maxRating - _minRating,
                      activeColor: _selectedColor,
                      onChanged: (value) {
                        setState(() {
                          _ratingValue = value;
                        });
                      },
                    ),
                  ),
                  Text('$_maxRating', style: theme.textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Текущее значение: ${_ratingValue.round()}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTextTypeContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Многострочное текстовое поле',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF374151),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Пользователь сможет вводить текст в свободной форме - заметки, описания, комментарии.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Пример текстового поля:',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Сегодня чувствую себя отлично! Много энергии, хорошее настроение...',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  String _getPreviewSubtitle() {
    switch (_dataType) {
      case 'Number':
        if (_unit.isNotEmpty) {
          return 'Последнее значение: 25 $_unit';
        }
        return 'Последнее значение: 25';
      case 'Rating':
        return 'Последняя оценка: ${_ratingValue.round()} (${_minRating}-$_maxRating)';
      case 'Text':
        return 'Заметка: Хорошее самочувствие';
      default:
        return 'Последнее значение: 5';
    }
  }

  /// Строит кнопки внизу экрана
  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: Colors.black.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                if (_currentStep == 0) {
                  Navigator.of(context).pop();
                } else {
                  setState(() {
                    _currentStep = 0;
                  });
                }
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              child: Text(_currentStep == 0 ? 'Отмена' : 'Назад'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: PrimaryButton(
              text: _currentStep == 0 ? 'Далее' : 'Сохранить изменения',
              onPressed: _parameterName.trim().isEmpty ? null : () {
                if (_currentStep == 0) {
                  setState(() {
                    _currentStep = 1;
                  });
                } else {
                  _updateParameter();
                }
              },
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _updateParameter() async {
    if (_parameterName.trim().isEmpty) {
      Get.snackbar(
        'Ошибка',
        'Введите название параметра',
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Подготовка scaleOptions
    List<String>? scaleOptions;
    
    // Сохраняем цвет для всех пользовательских параметров
    if (!widget.parameter.isPreset) {
      scaleOptions = [
        'color:${_selectedColor.value.toRadixString(16)}',
      ];
      
      if (_dataType == 'Rating') {
        scaleOptions.addAll([
          'min:$_minRating',
          'max:$_maxRating',
          'left:$_leftEdge',
          'right:$_rightEdge',
        ]);
      }
    } else {
      // Для пресет параметров оставляем существующие scaleOptions
      scaleOptions = widget.parameter.scaleOptions;
    }

    // Подготовка iconName
    String? iconName;
    if (!widget.parameter.isPreset) {
      iconName = _selectedIcon.codePoint.toString();
    } else {
      iconName = widget.parameter.iconName;
    }

    final updatedParameter = widget.parameter.copyWith(
      name: _parameterName.trim(),
      dataType: _dataType,
      unit: _unit.trim().isEmpty ? null : _unit.trim(),
      scaleOptions: scaleOptions,
      iconName: iconName,
    );

    try {
      await _parameterController.updateParameter(updatedParameter);

      Get.snackbar(
        'Успех',
        'Параметр "$_parameterName" обновлен успешно!',
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );

      Navigator.of(context).pop();
    } catch (e) {
      Get.snackbar(
        'Ошибка',
        'Ошибка при сохранении: $e',
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
        borderRadius: 12,
        duration: const Duration(seconds: 4),
      );
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    _leftEdgeController.dispose();
    _rightEdgeController.dispose();
    super.dispose();
  }
}