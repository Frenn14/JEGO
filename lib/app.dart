import 'package:flutter/material.dart';

import 'core/config/routes.dart';

// ✅ features import는 여기서만 (core에서 금지!)
import 'features/auth/presentation/pages/auth_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/inventory/presentation/pages/inventory_page.dart';
// 필요한 페이지 추가 import...

class App extends StatelessWidget {
  const App({super.key});

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.auth:
        return MaterialPageRoute(builder: (_) => const AuthPage());
      case AppRoutes.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardPage());
      case AppRoutes.inventory:
        return MaterialPageRoute(builder: (_) => const InventoryPage());

    // 예: args 받는 페이지는 settings.arguments 사용
    // case AppRoutes.adminEditProduct:
    //   final productId = settings.arguments as String;
    //   return MaterialPageRoute(builder: (_) => AdminEditProductPage(productId: productId));

      default:
        return MaterialPageRoute(builder: (_) => const AuthPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: AppRoutes.auth,
      onGenerateRoute: _onGenerateRoute,
      // theme: AppTheme.light, 등 기존 유지
    );
  }
}