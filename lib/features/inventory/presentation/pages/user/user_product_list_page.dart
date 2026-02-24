import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/spacing_system.dart';
import '../../../../../core/theme/text_system.dart';
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
    Future.microtask(() => context.read<InventoryListNotifier>().load());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = context.watch<InventoryListNotifier>();

    return AppScaffold(
      title: '제품 목록',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            hint: '검색 (이름/별칭/상품번호)',
            controller: _search,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (list.error != null) AppCard(child: Text('에러: ${list.error}', style: AppTextStyles.body)),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: list.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
              itemCount: list.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) {
                final p = list.items[i];
                return AppCard(
                  child: ListTile(
                    title: Text(p.name, style: AppTextStyles.body),
                    subtitle: Text('상품번호: ${p.productNo} / 현재 재고: ${p.totalQty}', style: AppTextStyles.body),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProductUsagePage(productNo: p.productNo)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _search.addListener(() {
      context.read<InventoryListNotifier>().setQuery(_search.text);
    });
  }
}