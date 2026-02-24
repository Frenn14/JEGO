import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/spacing_system.dart';
import '../../../../../core/theme/text_system.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/app_scaffold.dart';
import '../../../../../core/widgets/app_textfield.dart';
import '../../providers/inventory_list_notifier.dart';
import 'admin_product_create_page.dart';
import 'admin_product_edit_page.dart';

class AdminProductListPage extends StatefulWidget {
  const AdminProductListPage({super.key});

  @override
  State<AdminProductListPage> createState() => _AdminProductListPageState();
}

class _AdminProductListPageState extends State<AdminProductListPage> {
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
      title: '관리자: 제품 목록',
      body: Stack(
        children: [
          Column(
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
                        subtitle: Text('상품번호: ${p.productNo} / 수량: ${p.totalQty}', style: AppTextStyles.body),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AdminProductEditPage(productNo: p.productNo)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // FAB
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminProductCreatePage()));
                if (context.mounted) context.read<InventoryListNotifier>().load();
              },
              child: const Icon(Icons.add),
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