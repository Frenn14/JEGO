import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_notifier.dart';
import 'admin/admin_product_list_page.dart';
import 'user/user_product_list_page.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();

    if (auth.isAdmin) return const AdminProductListPage();
    return const UserProductListPage();
  }
}