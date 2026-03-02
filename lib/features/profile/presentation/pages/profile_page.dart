import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/spacing_system.dart';
import '../../../../core/theme/text_system.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();

    return AppScaffold(
      title: '프로필',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('UID', style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.xs),
                Text(auth.uid ?? '-', style: AppTextStyles.body),
                const SizedBox(height: AppSpacing.md),
                Text('Role', style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.xs),
                Text(auth.role, style: AppTextStyles.body),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            text: auth.isLoading ? '로그아웃 중...' : '로그아웃',
            onPressed: auth.isLoading
                ? null
                : () async {
              await context.read<AuthNotifier>().logout();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, '/auth', (_) => false);
            },
          ),
        ],
      ),
    );
  }
}