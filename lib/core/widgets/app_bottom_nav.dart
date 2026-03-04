import 'package:flutter/material.dart';
import '../config/routes.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
  });

  void _go(BuildContext context, int index) {
    String target;

    switch (index) {
      case 0:
        target = AppRoutes.dashboard;
        break;
      case 1:
        target = AppRoutes.inventory;
        break;
      case 2:
        target = AppRoutes.profile;
        break;
      default:
        target = AppRoutes.dashboard;
    }

    final currentRoute = ModalRoute.of(context)?.settings.name;

    // 같은 페이지면 이동 안함
    if (currentRoute == target) return;

    Navigator.pushReplacementNamed(context, target);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (i) => _go(context, i),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2),
          label: '인벤토리',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: '프로필',
        ),
      ],
    );
  }
}