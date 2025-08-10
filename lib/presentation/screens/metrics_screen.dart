import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/controllers/parameter_controller.dart';
import '../../domain/controllers/metrics_tab_controller.dart';
import '../widgets/parameter_list_widget.dart';
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
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          metricsTabController.isShowingParameterList.value 
            ? 'Управление параметрами' 
            : 'Метрики'
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        leading: metricsTabController.isShowingParameterList.value 
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => metricsTabController.showMetrics(),
            )
          : null,
        actions: metricsTabController.isShowingParameterList.value
          ? [
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Создать параметр',
                onPressed: () => Navigator.of(context).pushWithTransition(
                  const ParameterCreateScreen(),
                  transition: PageTransitionType.slideFromBottom,
                ),
              ),
            ]
          : null,
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.analytics,
                    color: theme.colorScheme.primary,
                    size: 32,
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
          ),
          
          const SizedBox(height: 16),
          
          // Кнопка управления параметрами - теперь вызывает контроллер
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => metricsTabController.showParameterList(),
              icon: const Icon(Icons.tune),
              label: const Text('Управлять параметрами'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
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
    
    return Card(
      child: Opacity(
        opacity: isComingSoon ? 0.6 : 1.0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium,
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
      ),
    );
  }
}