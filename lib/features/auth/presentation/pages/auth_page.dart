import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/routes.dart';
import '../../../../core/theme/spacing_system.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_textfield.dart';
import '../providers/auth_notifier.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이메일과 비밀번호를 입력해 주세요.'),
        ),
      );
      return;
    }

    final auth = context.read<AuthNotifier>();
    await auth.loginWithEmail(
      email: email,
      password: password,
    );

    if (!mounted) return;

    if (auth.uid != null) {
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(auth.error ?? '로그인에 실패했습니다.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();

    return AppScaffold(
      title: 'Login',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            hint: 'ID',
            controller: _emailController,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            hint: 'Password',
            controller: _passwordController,
            obscureText: true,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            text: auth.isLoading ? '로그인 중...' : 'Login',
            onPressed: auth.isLoading
                ? null
                : () async {
              await _login();
            },
          ),
        ],
      ),
    );
  }
}