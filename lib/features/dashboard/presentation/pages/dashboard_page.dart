import 'package:flutter/material.dart';

import '../../../../core/config/routes.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/theme/spacing_system.dart';
import '../../../../core/theme/text_system.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Dashboard',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('대시보드', style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '여기서 출석/재고/프로필 기능으로 이동합니다.',
                  style: AppTextStyles.body,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            text: 'Inventory로 이동',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.inventory),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            text: 'Profile로 이동',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
    );
  }
}