import 'package:flutter/material.dart';
import '../models/parameter.dart';

/// Система иконок для параметров - содержит все иконки для пресет параметров
class ParameterIcons {
  /// Карта иконок для пресет параметров
  static const Map<String, IconData> presetIcons = {
    'bedtime': Icons.bedtime,
    'medication': Icons.medication,
    'work': Icons.work,
    'fitness_center': Icons.fitness_center,
    'directions_walk': Icons.directions_walk,
    'people': Icons.people,
    'sentiment_satisfied': Icons.sentiment_satisfied,
    'favorite': Icons.favorite,
    'star': Icons.star,
    'restaurant': Icons.restaurant,
    'attach_money': Icons.attach_money,
    'public': Icons.public,
    'thumb_up': Icons.thumb_up,
    'edit_note': Icons.edit_note,
    'book': Icons.book,
  };
  
  /// Дефолтная иконка для пользовательских параметров
  static const IconData defaultIcon = Icons.analytics;
  
  /// Возвращает иконку для параметра
  static IconData getIcon(Parameter parameter) {
    if (parameter.isPreset && parameter.iconName != null) {
      return presetIcons[parameter.iconName!] ?? defaultIcon;
    }
    return defaultIcon; // Дефолтная иконка для пользовательских параметров
  }
  
  /// Возвращает иконку по названию (для отладки)
  static IconData getIconByName(String? iconName) {
    if (iconName == null) return defaultIcon;
    return presetIcons[iconName] ?? defaultIcon;
  }
  
  /// Возвращает все доступные иконки для выбора (для создания пользовательских параметров)
  static Map<String, IconData> getAllAvailableIcons() {
    return {
      ...presetIcons,
      'analytics': Icons.analytics,
      'tune': Icons.tune,
      'settings': Icons.settings,
      'info': Icons.info,
      'track_changes': Icons.track_changes,
      'trending_up': Icons.trending_up,
      'assessment': Icons.assessment,
      'bar_chart': Icons.bar_chart,
      'pie_chart': Icons.pie_chart,
      'show_chart': Icons.show_chart,
    };
  }
  
  /// Возвращает цвет иконки в зависимости от типа параметра
  static Color getIconColor(Parameter parameter, ColorScheme colorScheme) {
    if (parameter.isPreset) {
      // Для пресет параметров используем основной цвет темы
      return colorScheme.primary;
    } else {
      // Для пользовательских параметров используем вторичный цвет
      return colorScheme.secondary;
    }
  }
  
  /// Возвращает цвет фона для иконки
  static Color getIconBackgroundColor(Parameter parameter, ColorScheme colorScheme) {
    if (parameter.isPreset) {
      // Для пресет параметров используем контейнер основного цвета
      return colorScheme.primaryContainer;
    } else {
      // Для пользовательских параметров используем контейнер вторичного цвета  
      return colorScheme.secondaryContainer;
    }
  }
  
  /// Создает виджет иконки для параметра с правильными цветами
  static Widget buildParameterIcon(
    Parameter parameter, 
    BuildContext context, {
    double size = 24.0,
    double padding = 12.0,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: getIconBackgroundColor(parameter, colorScheme),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        getIcon(parameter),
        color: getIconColor(parameter, colorScheme),
        size: size,
      ),
    );
  }
  
  /// Создает компактную иконку без фона (для использования в списках)
  static Widget buildCompactIcon(
    Parameter parameter, 
    BuildContext context, {
    double size = 20.0,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Icon(
      getIcon(parameter),
      color: getIconColor(parameter, colorScheme),
      size: size,
    );
  }
}