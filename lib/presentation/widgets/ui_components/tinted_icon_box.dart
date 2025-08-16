import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Переиспользуемый компонент для иконок с тинтованным фоном
/// Реализует стиль .tint-box из layout.html:
/// - background: var(--tint) (#e8f1e3)
/// - color: var(--brand) (#88A874)
/// - Закругленные углы
class TintedIconBox extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? iconColor;

  const TintedIconBox({
    Key? key,
    required this.icon,
    this.size = 56,
    this.iconSize = 24,
    this.margin,
    this.backgroundColor,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.tintGreen, // --tint: #e8f1e3
        borderRadius: BorderRadius.circular(size / 2), // Круглый
      ),
      child: Center(
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor ?? AppTheme.brandGreen, // --brand: #88A874
        ),
      ),
    );
  }
}

/// Маленький вариант для списков параметров
class SmallTintedIconBox extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? iconColor;

  const SmallTintedIconBox({
    Key? key,
    required this.icon,
    this.size = 40,
    this.iconSize = 20,
    this.margin,
    this.backgroundColor,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TintedIconBox(
      icon: icon,
      size: size,
      iconSize: iconSize,
      margin: margin,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
    );
  }
}

/// Еще меньший вариант для компактных элементов
class TinyTintedIconBox extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? iconColor;

  const TinyTintedIconBox({
    Key? key,
    required this.icon,
    this.size = 28,
    this.iconSize = 16,
    this.margin,
    this.backgroundColor,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TintedIconBox(
      icon: icon,
      size: size,
      iconSize: iconSize,
      margin: margin,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
    );
  }
}