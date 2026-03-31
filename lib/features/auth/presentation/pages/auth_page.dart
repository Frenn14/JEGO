import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_textfield.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/theme/spacing_system.dart';
import '../providers/auth_notifier.dart';
import '../../../../core/config/routes.dart';

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
        const SnackBar(content: Text('이메일/비밀번호를 입력해 주세요.')),
      );
      return;
    }

    final auth = context.read<AuthNotifier>();
    await auth.loginWithEmail(email: email, password: password);

    if (!mounted) return;

    if (auth.uid != null) {
      // 로그인 성공 → 대시보드로 이동 (거기서 Inventory로 들어가면 admin/user 분기됨)
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    } else {
      // 실패 → 에러 표시
      final msg = auth.error ?? '로그인에 실패했습니다.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();

    return AppScaffold(
      title: 'Login',
      body: Column(
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
            onPressed: auth.isLoading ? null : _login,
          ),
        ],
      ),
    );
  }
}