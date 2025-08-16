import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/controllers/daily_record_controller.dart';
import '../widgets/ui_components/index.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dailyRecordController = Get.find<DailyRecordController>();
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Настройки'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.brandGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Секция экспорта данных
            Text(
              'Экспорт и резервное копирование',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Сохраните ваши данные или поделитесь ими',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            
            // Кнопка экспорта
            PrimaryButton(
              text: 'Экспортировать данные в CSV',
              icon: Icons.share,
              onPressed: () {
                dailyRecordController.exportDataAndShare();
              },
              width: double.infinity,
            ),
            
            
            const SizedBox(height: 32),
            
            // Секция настроек приложения
            Text(
              'Настройки приложения',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            
            // Заглушки для будущих настроек
            _buildSettingCard(
              context,
              icon: Icons.notifications,
              title: 'Уведомления',
              description: 'Напоминания о вводе данных',
              isComingSoon: true,
            ),
            
            const SizedBox(height: 12),
            
            _buildSettingCard(
              context,
              icon: Icons.palette,
              title: 'Тема оформления',
              description: 'Светлая, темная или автоматическая',
              isComingSoon: true,
            ),
            
            const SizedBox(height: 12),
            
            _buildSettingCard(
              context,
              icon: Icons.cloud_sync,
              title: 'Синхронизация',
              description: 'Резервное копирование в облако',
              isComingSoon: true,
            ),
            
            const SizedBox(height: 32),
            
            // Информация о приложении
            Text(
              'О приложении',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            
            AppCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      TintedIconBox(
                        icon: Icons.health_and_safety,
                        size: 56,
                        iconSize: 28,
                      ),
                      const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BioLogger',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Трекер здоровья и самочувствия',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Версия: 1.0.0',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.snackbar(
                              'Отладка',
                              'Функция отладки временно отключена',
                              snackPosition: SnackPosition.TOP,
                              margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
                              backgroundColor: Get.theme.colorScheme.secondaryContainer,
                              colorText: Get.theme.colorScheme.onSecondaryContainer,
                              borderRadius: 12,
                              duration: const Duration(seconds: 3),
                            );
                          },
                          child: const Text('Отладка'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }


  Widget _buildSettingCard(
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
    );
  }
}