import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'parameter_list_screen.dart';
import 'data_entry_screen.dart';
import '../../domain/controllers/daily_record_controller.dart';
import '../../domain/controllers/parameter_controller.dart';
import '../theme/app_theme.dart';
import '../animations/page_transitions.dart';

class HomeScreen extends StatelessWidget {
  final DailyRecordController dailyRecordController = Get.find();
  final ParameterController parameterController = Get.find();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Современный SliverAppBar с градиентом
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: theme.colorScheme.primary,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'BioLogger',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.health_and_safety,
                      size: 80,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ),
            
            // Контент с карточками
            SliverPadding(
              padding: AppTheme.pagePadding,
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 24),
                  
                  // Приветственный текст
                  Text(
                    'Добро пожаловать!',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Отслеживайте свое здоровье и самочувствие каждый день',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Статистика (заглушка)
                  Card(
                    child: Padding(
                      padding: AppTheme.cardPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.analytics_outlined,
                                color: theme.colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Статистика',
                                style: theme.textTheme.titleLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Obx(() {
                            final paramCount = parameterController.parameters.length;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _StatItem(
                                  label: 'Параметров',
                                  value: paramCount.toString(),
                                  icon: Icons.settings,
                                  theme: theme,
                                ),
                                _StatItem(
                                  label: 'Сегодня',
                                  value: '0', // TODO: добавить реальную статистику
                                  icon: Icons.today,
                                  theme: theme,
                                ),
                                _StatItem(
                                  label: 'Всего дней',
                                  value: '0', // TODO: добавить реальную статистику  
                                  icon: Icons.calendar_month,
                                  theme: theme,
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Основные действия
                  _ActionCard(
                    title: 'Управление параметрами',
                    subtitle: 'Создавайте и редактируйте параметры для отслеживания',
                    icon: Icons.tune,
                    theme: theme,
                    onTap: () => Navigator.of(context).pushWithTransition(
                      ParameterListScreen(),
                      transition: PageTransitionType.slideAndFade,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _ActionCard(
                    title: 'Ввод данных',
                    subtitle: 'Записывайте значения параметров за день',
                    icon: Icons.edit_note,
                    theme: theme,
                    onTap: () => Navigator.of(context).pushWithTransition(
                      DataEntryScreen(),
                      transition: PageTransitionType.slideAndFade,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _ActionCard(
                    title: 'Экспорт данных',
                    subtitle: 'Поделитесь своими данными или сохраните их',
                    icon: Icons.share,
                    theme: theme,
                    onTap: () => dailyRecordController.exportDataAndShare(),
                  ),
                  
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final ThemeData theme;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final ThemeData theme;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
        child: Padding(
          padding: AppTheme.cardPadding,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
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
                    Text(
                      title,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: theme.colorScheme.onSurfaceVariant,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}