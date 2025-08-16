import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/controllers/parameter_controller.dart';
import '../../domain/controllers/metrics_tab_controller.dart';
import '../widgets/parameter_list_widget.dart';
import '../widgets/ui_components/index.dart';
import '../theme/app_theme.dart';
import '../animations/page_transitions.dart';
import 'parameter_create_screen.dart';

class MetricsScreen extends StatelessWidget {
  const MetricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parameterController = Get.find<ParameterController>();
    final metricsTabController = Get.find<MetricsTabController>();
    
    return Obx(() => Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          metricsTabController.isShowingParameterList.value 
            ? 'Управление параметрами' 
            : 'Данные'
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.brandGreen,
        foregroundColor: Colors.white,
        leading: metricsTabController.isShowingParameterList.value 
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => metricsTabController.showMetrics(),
            )
          : null,
        actions: null,
      ),
      body: metricsTabController.isShowingParameterList.value
        ? ParameterListWidget() // Новый виджет без Scaffold
        : _buildMetricsContent(context, theme, parameterController, metricsTabController), // Текущий контент метрик
    ));
  }
  
  /// Строим содержимое экрана метрик
  Widget _buildMetricsContent(
    BuildContext context, 
    ThemeData theme, 
    ParameterController parameterController,
    MetricsTabController metricsTabController
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок секции
          Text(
            'Управление параметрами',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Создавайте и редактируйте параметры для отслеживания',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          
          // Статистика параметров
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                TintedIconBox(
                  icon: Icons.analytics,
                  size: 56,
                  iconSize: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Параметры для отслеживания',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                        'Всего создано: ${parameterController.parameters.length}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      )),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Кнопка управления параметрами - теперь вызывает контроллер
          PrimaryButton(
            text: 'Управлять параметрами',
            icon: Icons.tune,
            onPressed: () => metricsTabController.showParameterList(),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          
          const SizedBox(height: 32),
          
          // Будущие метрики (заглушки)
          Text(
            'Статистика и анализ',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Скоро здесь появятся графики и анализ ваших данных',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          
          // Заглушки для будущих метрик
          _buildMetricCard(
            context,
            icon: Icons.trending_up,
            title: 'Тренды и динамика',
            description: 'Анализ изменений параметров со временем',
            isComingSoon: true,
          ),
          
          const SizedBox(height: 12),
          
          _buildMetricCard(
            context,
            icon: Icons.bar_chart,
            title: 'Сравнительная статистика',
            description: 'Сравнение показателей за разные периоды',
            isComingSoon: true,
          ),
          
          const SizedBox(height: 12),
          
          _buildMetricCard(
            context,
            icon: Icons.insights,
            title: 'Корреляции',
            description: 'Взаимосвязи между различными параметрами',
            isComingSoon: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    bool isComingSoon = false,
  }) {
    final theme = Theme.of(context);
    
    return AppCard(
      child: Opacity(
        opacity: isComingSoon ? 0.6 : 1.0,
        child: Row(
          children: [
            SmallTintedIconBox(
              icon: icon,
              size: 48,
              iconSize: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isComingSoon) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Скоро',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (!isComingSoon)
              Icon(
                Icons.arrow_forward_ios,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}