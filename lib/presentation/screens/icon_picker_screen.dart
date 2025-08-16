import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class IconPickerScreen extends StatefulWidget {
  final IconData? selectedIcon;
  final Color selectedColor;
  
  const IconPickerScreen({
    Key? key, 
    this.selectedIcon,
    required this.selectedColor,
  }) : super(key: key);

  @override
  State<IconPickerScreen> createState() => _IconPickerScreenState();
}

class _IconPickerScreenState extends State<IconPickerScreen> {
  String _selectedCategory = 'Все';
  IconData? _currentSelection;
  
  // Категории иконок
  final Map<String, List<IconData>> _iconCategories = {
    'Все': [],
    'Активность': [
      Icons.directions_walk,
      Icons.directions_run,
      Icons.directions_bike,
      Icons.pool,
      Icons.fitness_center,
      Icons.sports_tennis,
      Icons.sports_soccer,
      Icons.sports_basketball,
      Icons.sports_volleyball,
      Icons.sports_baseball,
      Icons.sports_football,
      Icons.sports_golf,
      Icons.rowing,
      Icons.surfing,
      Icons.snowboarding,
      Icons.downhill_skiing,
      Icons.hiking,
      Icons.nature_people,
    ],
    'Настроение': [
      Icons.sentiment_very_satisfied,
      Icons.sentiment_satisfied,
      Icons.sentiment_neutral,
      Icons.sentiment_dissatisfied,
      Icons.sentiment_very_dissatisfied,
      Icons.mood,
      Icons.mood_bad,
      Icons.psychology,
      Icons.self_improvement,
      Icons.face,
      Icons.emoji_emotions,
      Icons.sick,
      Icons.healing,
    ],
    'Сон': [
      Icons.bedtime,
      Icons.nightlight,
      Icons.dark_mode,
      Icons.light_mode,
      Icons.brightness_2,
      Icons.brightness_3,
      Icons.alarm,
      Icons.snooze,
      Icons.hotel,
    ],
    'Еда': [
      Icons.restaurant,
      Icons.local_dining,
      Icons.fastfood,
      Icons.lunch_dining,
      Icons.breakfast_dining,
      Icons.dinner_dining,
      Icons.coffee,
      Icons.local_cafe,
      Icons.local_bar,
      Icons.wine_bar,
      Icons.liquor,
      Icons.cake,
      Icons.cookie,
      Icons.icecream,
      Icons.apple,
      Icons.restaurant_menu,
      Icons.kitchen,
      Icons.microwave,
      Icons.blender,
    ],
    'Здоровье': [
      Icons.favorite,
      Icons.medical_services,
      Icons.medication,
      Icons.vaccines,
      Icons.monitor_heart,
      Icons.thermostat,
      Icons.bloodtype,
      Icons.emergency,
      Icons.local_hospital,
      Icons.local_pharmacy,
      Icons.healing,
      Icons.masks,
      Icons.sanitizer,
      Icons.wash,
      Icons.soap,
    ],
    'Работа': [
      Icons.work,
      Icons.business,
      Icons.laptop,
      Icons.computer,
      Icons.phone,
      Icons.email,
      Icons.schedule,
      Icons.event,
      Icons.meeting_room,
      Icons.groups,
      Icons.person,
      Icons.assignment,
      Icons.task,
      Icons.check_circle,
      Icons.pending,
      Icons.timer,
      Icons.today,
      Icons.date_range,
    ],
    'Деньги': [
      Icons.attach_money,
      Icons.monetization_on,
      Icons.payment,
      Icons.account_balance,
      Icons.credit_card,
      Icons.savings,
      Icons.currency_exchange,
      Icons.price_change,
      Icons.trending_up,
      Icons.trending_down,
      Icons.analytics,
      Icons.calculate,
      Icons.receipt,
      Icons.shopping_cart,
      Icons.store,
    ],
    'Транспорт': [
      Icons.directions_car,
      Icons.directions_bus,
      Icons.directions_subway,
      Icons.train,
      Icons.flight,
      Icons.directions_boat,
      Icons.motorcycle,
      Icons.electric_scooter,
      Icons.pedal_bike,
      Icons.local_taxi,
      Icons.local_shipping,
      Icons.delivery_dining,
      Icons.traffic,
      Icons.map,
      Icons.navigation,
      Icons.location_on,
    ],
  };
  
  @override
  void initState() {
    super.initState();
    _currentSelection = widget.selectedIcon;
    
    // Создаем список "Все" объединив все категории
    final allIcons = <IconData>[];
    _iconCategories.forEach((category, icons) {
      if (category != 'Все') {
        allIcons.addAll(icons);
      }
    });
    _iconCategories['Все'] = allIcons;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Выбор иконки'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.brandGreen,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _currentSelection != null ? () {
              Navigator.of(context).pop(_currentSelection);
            } : null,
            child: Text(
              'Применить',
              style: TextStyle(
                color: _currentSelection != null ? Colors.white : Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Категории
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _iconCategories.keys.length,
              itemBuilder: (context, index) {
                final category = _iconCategories.keys.elementAt(index);
                final isSelected = _selectedCategory == category;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.brandGreen.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppTheme.brandGreen : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isSelected ? AppTheme.brandGreen : const Color(0xFF6B7280),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Сетка иконок
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: _iconCategories[_selectedCategory]?.length ?? 0,
              itemBuilder: (context, index) {
                final icon = _iconCategories[_selectedCategory]![index];
                final isSelected = _currentSelection == icon;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentSelection = icon;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? widget.selectedColor.withOpacity(0.2) : AppTheme.tintGreen,
                      borderRadius: BorderRadius.circular(24),
                      border: isSelected 
                        ? Border.all(color: widget.selectedColor, width: 2)
                        : null,
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? widget.selectedColor : AppTheme.brandGreen,
                      size: 24,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}