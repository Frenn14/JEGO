import 'package:flutter/material.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_textfield.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/theme/spacing_system.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return AppScaffold(
      title: 'Login',
      body: Column(
        children: [
          AppTextField(
            hint: 'ID',
            controller: emailController,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            hint: 'Password',
            controller: passwordController,
            obscureText: true,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            text: 'Login',
            onPressed: () {
              // Provider 연결은 다음 단계에서
            },
          ),
        ],
      ),
    );
  }
}