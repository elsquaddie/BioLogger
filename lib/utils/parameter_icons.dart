import 'package:flutter/material.dart';
import '../models/parameter.dart';
import '../presentation/widgets/ui_components/tinted_icon_box.dart';

/// Система иконок для параметров - содержит все иконки для пресет параметров
class ParameterIcons {
  /// Карта иконок для пресет параметров (обновлено под layout.html)
  static const Map<String, IconData> presetIcons = {
    'bedtime': Icons.bedtime,
    'medication': Icons.medication,
    'work': Icons.work,
    'fitness_center': Icons.fitness_center,
    'directions_walk': Icons.directions_walk,
    'groups': Icons.groups, // Обновлено: было 'people'
    'sentiment_satisfied': Icons.sentiment_satisfied,
    'favorite': Icons.favorite,
    'star': Icons.star,
    'restaurant': Icons.restaurant,
    'attach_money': Icons.attach_money,
    'public': Icons.public,
    'thumb_up': Icons.thumb_up,
    'edit_note': Icons.edit_note,
    'menu_book': Icons.menu_book, // Обновлено: было 'book'
    
    // Дополнительные иконки из макета
    'local_fire_department': Icons.local_fire_department,
    'event': Icons.event,
  };
  
  /// Дефолтная иконка для пользовательских параметров
  static const IconData defaultIcon = Icons.analytics;
  
  /// Возвращает иконку для параметра
  static IconData getIcon(Parameter parameter) {
    if (parameter.iconName != null) {
      // Для пресет параметров используем имена иконок
      if (parameter.isPreset) {
        return presetIcons[parameter.iconName!] ?? defaultIcon;
      } else {
        // Для пользовательских параметров восстанавливаем иконку из codePoint
        final codePoint = int.tryParse(parameter.iconName!);
        if (codePoint != null) {
          return IconData(codePoint, fontFamily: 'MaterialIcons');
        }
      }
    }
    return defaultIcon; // Дефолтная иконка
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
      // Для пользовательских параметров извлекаем цвет из scaleOptions
      final customColor = getCustomColor(parameter);
      return customColor ?? colorScheme.secondary;
    }
  }
  
  /// Извлекает пользовательский цвет из scaleOptions
  static Color? getCustomColor(Parameter parameter) {
    if (parameter.scaleOptions != null) {
      for (String option in parameter.scaleOptions!) {
        if (option.startsWith('color:')) {
          final colorHex = option.substring(6);
          try {
            // Парсим hex значение, добавляя префикс 0xFF если не полный
            int colorValue;
            if (colorHex.length == 8) {
              // Полный hex с альфа каналом (AARRGGBB)
              colorValue = int.parse(colorHex, radix: 16);
            } else if (colorHex.length == 6) {
              // RGB без альфа канала, добавляем FF в начало
              colorValue = int.parse('FF$colorHex', radix: 16);
            } else {
              print('Invalid color hex length: $colorHex');
              return null;
            }
            
            print('ParameterIcons: Parsed color from "$option" -> 0x${colorValue.toRadixString(16)}');
            return Color(colorValue);
          } catch (e) {
            print('Error parsing color from scaleOptions: $e, hex: $colorHex');
          }
          break;
        }
      }
    }
    return null;
  }
  
  /// Возвращает цвет фона для иконки
  static Color getIconBackgroundColor(Parameter parameter, ColorScheme colorScheme) {
    if (parameter.isPreset) {
      // Для пресет параметров используем контейнер основного цвета
      return colorScheme.primaryContainer;
    } else {
      // Для пользовательских параметров используем светлую версию пользовательского цвета
      final customColor = getCustomColor(parameter);
      if (customColor != null) {
        return customColor.withOpacity(0.1);
      }
      return colorScheme.secondaryContainer;
    }
  }
  
  /// Создает виджет иконки для параметра в новом стиле (TintedIconBox)
  static Widget buildParameterIcon(
    Parameter parameter, 
    BuildContext context, {
    double size = 56.0,
    double iconSize = 24.0,
    EdgeInsetsGeometry? margin,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return TintedIconBox(
      icon: getIcon(parameter),
      size: size,
      iconSize: iconSize,
      margin: margin,
      backgroundColor: getIconBackgroundColor(parameter, colorScheme),
      iconColor: getIconColor(parameter, colorScheme),
    );
  }
  
  /// Создает малую иконку для списков параметров
  static Widget buildSmallParameterIcon(
    Parameter parameter, 
    BuildContext context, {
    double size = 40.0,
    double iconSize = 20.0,
    EdgeInsetsGeometry? margin,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return SmallTintedIconBox(
      icon: getIcon(parameter),
      size: size,
      iconSize: iconSize,
      margin: margin,
      backgroundColor: getIconBackgroundColor(parameter, colorScheme),
      iconColor: getIconColor(parameter, colorScheme),
    );
  }
  
  /// Создает крошечную иконку для компактных элементов
  static Widget buildTinyParameterIcon(
    Parameter parameter, 
    BuildContext context, {
    double size = 28.0,
    double iconSize = 16.0,
    EdgeInsetsGeometry? margin,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return TinyTintedIconBox(
      icon: getIcon(parameter),
      size: size,
      iconSize: iconSize,
      margin: margin,
      backgroundColor: getIconBackgroundColor(parameter, colorScheme),
      iconColor: getIconColor(parameter, colorScheme),
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