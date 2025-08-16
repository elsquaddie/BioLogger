import 'package:flutter/material.dart';

/// Переиспользуемый компонент карточки в стиле дизайн-системы
/// Реализует стиль .card из layout.html:
/// - Белый фон
/// - borderRadius: 1.25rem (20px)
/// - box-shadow и border
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const AppCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // 1.25rem
        boxShadow: [
          BoxShadow(
            color: const Color(0x10101828), // rgba(16,24,40,.06)
            offset: const Offset(0, 1),
            blurRadius: 2,
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: const Color(0x10101828), // rgba(16,24,40,.06)
          width: 1,
        ),
      ),
      child: child,
    );
  }
}