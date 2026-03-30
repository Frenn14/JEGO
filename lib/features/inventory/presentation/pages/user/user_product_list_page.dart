import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/spacing_system.dart';
import '../../../../../core/theme/text_system.dart';
import '../../../../../core/widgets/app_bottom_nav.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/app_scaffold.dart';
import '../../../../../core/widgets/app_textfield.dart';
import '../../providers/inventory_list_notifier.dart';
import 'product_usage_page.dart';

class UserProductListPage extends StatefulWidget {
  const UserProductListPage({super.key});

  @override
  State<UserProductListPage> createState() => _UserProductListPageState();
}

class _UserProductListPageState extends State<UserProductListPage> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController();
    _search.addListener(_onSearchChanged);

    Future.microtask(() {
      context.read<InventoryListNotifier>().load();
    });
  }

  void _onSearchChanged() {
    context.read<InventoryListNotifier>().setQuery(_search.text);
  }

  @override
  void dispose() {
    _search.removeListener(_onSearchChanged);
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = context.watch<InventoryListNotifier>();

    return AppScaffold(
      title: '제품 목록',
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            hint: '검색 (이름/별칭/상품번호)',
            controller: _search,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (list.error != null)
            AppCard(
              child: Text(
                '에러: ${list.error}',
                style: AppTextStyles.body,
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: list.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
              itemCount: list.items.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final product = list.items[index];

                return AppCard(
                  child: ListTile(
                    title: Text(
                      product.name,
                      style: AppTextStyles.body,
                    ),
                    subtitle: Text(
                      '상품번호: ${product.productNo} / 현재 재고: ${product.totalQty}',
                      style: AppTextStyles.body,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductUsagePage(
                            productNo: product.productNo,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}