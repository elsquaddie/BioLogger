import 'package:flutter/material.dart';

/// Кастомные анимации переходов между экранами для улучшения UX
class PageTransitions {
  /// Плавный переход с прозрачностью и масштабированием
  static Route<T> fadeScale<T extends Object?>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.easeInOut;

        var fadeAnimation = Tween(begin: begin, end: end).animate(
          CurvedAnimation(parent: animation, curve: curve),
        );

        var scaleAnimation = Tween(begin: 0.95, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: curve),
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// Слайд переход справа налево
  static Route<T> slideFromRight<T extends Object?>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Слайд переход снизу вверх (для модальных экранов)
  static Route<T> slideFromBottom<T extends Object?>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Комбинированный переход: слайд + прозрачность
  static Route<T> slideAndFade<T extends Object?>(Widget page, {SlideDirection direction = SlideDirection.right}) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        Offset begin;
        switch (direction) {
          case SlideDirection.right:
            begin = const Offset(1.0, 0.0);
            break;
          case SlideDirection.left:
            begin = const Offset(-1.0, 0.0);
            break;
          case SlideDirection.up:
            begin = const Offset(0.0, 1.0);
            break;
          case SlideDirection.down:
            begin = const Offset(0.0, -1.0);
            break;
        }

        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var slideTween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(slideTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    );
  }

  /// Hero-анимация с дополнительным fade эффектом
  static Route<T> heroFade<T extends Object?>(Widget page, {required String heroTag}) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 600),
      reverseTransitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOutCubic;

        var fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: curve),
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: child,
        );
      },
    );
  }

  /// Переход с "shared element" эффектом
  static Route<T> sharedAxisTransition<T extends Object?>(Widget page, {SharedAxisTransitionType type = SharedAxisTransitionType.horizontal}) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOut;
        
        if (type == SharedAxisTransitionType.horizontal) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.3, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: curve)),
            child: FadeTransition(
              opacity: Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(CurvedAnimation(parent: animation, curve: curve)),
              child: child,
            ),
          );
        } else {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.3),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: curve)),
            child: FadeTransition(
              opacity: Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(CurvedAnimation(parent: animation, curve: curve)),
              child: child,
            ),
          );
        }
      },
    );
  }
}

/// Направления для слайд анимаций
enum SlideDirection {
  right,
  left,
  up,
  down,
}

/// Типы shared axis переходов
enum SharedAxisTransitionType {
  horizontal,
  vertical,
}

/// Расширение для Navigator для удобного использования
extension NavigatorExtension on NavigatorState {
  Future<T?> pushWithTransition<T extends Object?>(
    Widget page, {
    PageTransitionType transition = PageTransitionType.slideAndFade,
    SlideDirection direction = SlideDirection.right,
  }) {
    late Route<T> route;
    
    switch (transition) {
      case PageTransitionType.fadeScale:
        route = PageTransitions.fadeScale<T>(page);
        break;
      case PageTransitionType.slideFromRight:
        route = PageTransitions.slideFromRight<T>(page);
        break;
      case PageTransitionType.slideFromBottom:
        route = PageTransitions.slideFromBottom<T>(page);
        break;
      case PageTransitionType.slideAndFade:
        route = PageTransitions.slideAndFade<T>(page, direction: direction);
        break;
      case PageTransitionType.sharedAxis:
        route = PageTransitions.sharedAxisTransition<T>(page);
        break;
    }
    
    return push<T>(route);
  }
}

enum PageTransitionType {
  fadeScale,
  slideFromRight,
  slideFromBottom,
  slideAndFade,
  sharedAxis,
}