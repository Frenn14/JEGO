import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/inventory/presentation/pages/inventory_page.dart';

class AppRoutes {
  AppRoutes._();

  // Route Names
  static const String splash = '/';
  static const String auth = '/auth';
  static const String dashboard = '/dashboard';
  static const String inventory = '/inventory';
  static const String profile = '/profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const _SplashPage());

      case auth:
        return _buildRoute(const AuthPage());

      case dashboard:
        return _buildRoute(const DashboardPage());

      case inventory:
        return _buildRoute(const InventoryPage());

      case profile:
        return _buildRoute(const _ProfilePlaceholder());

      default:
        return _buildRoute(const _UnknownPage());
    }
  }

  static MaterialPageRoute _buildRoute(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }
}

class _SplashPage extends StatelessWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context) {
    Future.microtask(() {
      Navigator.pushReplacementNamed(context, AppRoutes.auth);
    });

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Profile Page'),
      ),
    );
  }
}

class _UnknownPage extends StatelessWidget {
  const _UnknownPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('404 - Page Not Found'),
      ),
    );
  }
}