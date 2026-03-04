import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/routes.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';

// ✅ features import는 app.dart에서만
import 'features/auth/presentation/pages/auth_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/inventory/presentation/pages/inventory_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const _SplashPage());

      case AppRoutes.auth:
        return MaterialPageRoute(builder: (_) => const AuthPage());

      case AppRoutes.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardPage());

      case AppRoutes.inventory:
        return MaterialPageRoute(builder: (_) => const InventoryPage());

      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());

      default:
        return MaterialPageRoute(builder: (_) => const _UnknownPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeProvider.themeMode,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: _onGenerateRoute,
    );
  }
}

class _SplashPage extends StatelessWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context) {
    Future.microtask(() {
      // ✅ 여기서는 일단 auth로 (원하면 uid 있으면 dashboard로 바로 보내는 로직도 가능)
      Navigator.pushReplacementNamed(context, AppRoutes.auth);
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _UnknownPage extends StatelessWidget {
  const _UnknownPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('404 - Page Not Found')),
    );
  }
}