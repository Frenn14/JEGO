import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/spacing_system.dart';
import '../../../../../core/theme/text_system.dart';
import '../../../../../core/widgets/app_bottom_nav.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/app_scaffold.dart';
import '../../../../../core/widgets/app_textfield.dart';
import '../../../../auth/presentation/providers/auth_notifier.dart';
import '../../providers/product_usage_notifier.dart';

class ProductUsagePage extends StatefulWidget {
  final String productNo;

  const ProductUsagePage({
    super.key,
    required this.productNo,
  });

  @override
  State<ProductUsagePage> createState() => _ProductUsagePageState();
}

class _ProductUsagePageState extends State<ProductUsagePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _qtyController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _qtyController = TextEditingController(text: '1');

    Future.microtask(() async {
      final auth = context.read<AuthNotifier>();
      final uid = auth.uid;

      if (uid == null) return;

      await context.read<ProductUsageNotifier>().load(
        uid: uid,
        productNo: widget.productNo,
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _checkout(String uid) async {
    final qty = int.tryParse(_qtyController.text.trim()) ?? 0;
    if (qty <= 0) return;

    await context.read<ProductUsageNotifier>().checkout(
      uid: uid,
      productNo: widget.productNo,
      qty: qty,
    );
  }

  Future<void> _returnItem(String uid, int myBorrowed) async {
    final qty = int.tryParse(_qtyController.text.trim()) ?? 0;
    if (qty <= 0) return;

    if (qty > myBorrowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('반납 수량이 내가 빌린 수량보다 큽니다.'),
        ),
      );
      return;
    }

    await context.read<ProductUsageNotifier>().returnItem(
      uid: uid,
      productNo: widget.productNo,
      qty: qty,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    final usage = context.watch<ProductUsageNotifier>();
    final uid = auth.uid;
    final product = usage.product;

    if (uid == null) {
      return AppScaffold(
        title: '사용/반납',
        body: AppCard(
          child: Text(
            '로그인이 필요합니다.',
            style: AppTextStyles.body,
          ),
        ),
      );
    }

    final currentQty = product?.totalQty ?? 0;
    final myBorrowed = usage.myBorrowed;
    final canCheckout = !usage.isLoading && currentQty > 0;
    final canReturn = !usage.isLoading && myBorrowed > 0;

    return AppScaffold(
      title: '사용/반납',
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (usage.error != null)
            AppCard(
              child: Text(
                '에러: ${usage.error}',
                style: AppTextStyles.body,
              ),
            ),
          AppCard(
            child: Row(
              children: [
                _Thumb(imageUrl: product?.imageUrl),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product?.name ?? '로딩...',
                        style: AppTextStyles.title,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '현재 재고: $currentQty',
                        style: AppTextStyles.body,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      LinearProgressIndicator(
                        value: currentQty > 0 ? 1.0 : 0.0,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '제품 ID: ${widget.productNo}',
                        style: AppTextStyles.body,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '내가 빌린 수량: $myBorrowed',
                        style: AppTextStyles.body,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            hint: '수량',
            controller: _qtyController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: canCheckout ? '사용' : '사용 불가',
                  onPressed: canCheckout
                      ? () async {
                    await _checkout(uid);
                  }
                      : null,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  text: canReturn ? '반납' : '반납 불가',
                  onPressed: canReturn
                      ? () async {
                    await _returnItem(uid, myBorrowed);
                  }
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '로그'),
              Tab(text: 'Info'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _LogsTab(),
                _InfoTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogsTab extends StatelessWidget {
  const _LogsTab();

  @override
  Widget build(BuildContext context) {
    final usage = context.watch<ProductUsageNotifier>();

    if (usage.isLoading && usage.logs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (usage.logs.isEmpty) {
      return Center(
        child: Text(
          '로그가 없습니다.',
          style: AppTextStyles.body,
        ),
      );
    }

    return ListView.separated(
      itemCount: usage.logs.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final log = usage.logs[index];
        final label = log.type == 'checkout' ? '사용' : '반납';

        return AppCard(
          child: Text(
            '$label x${log.qty} | uid:${log.uid} | ${log.createdAt}',
            style: AppTextStyles.body,
          ),
        );
      },
    );
  }
}

class _InfoTab extends StatelessWidget {
  const _InfoTab();

  @override
  Widget build(BuildContext context) {
    final product = context.watch<ProductUsageNotifier>().product;

    if (product == null) {
      return Center(
        child: Text(
          '정보를 불러오는 중...',
          style: AppTextStyles.body,
        ),
      );
    }

    return ListView(
      children: [
        AppCard(
          child: Text(
            '상품번호: ${product.productNo}',
            style: AppTextStyles.body,
          ),
        ),
        AppCard(
          child: Text(
            '이름: ${product.name}',
            style: AppTextStyles.body,
          ),
        ),
        AppCard(
          child: Text(
            '별칭: ${product.aliases.join(", ")}',
            style: AppTextStyles.body,
          ),
        ),
        AppCard(
          child: Text(
            '이미지 URL: ${product.imageUrl ?? "-"}',
            style: AppTextStyles.body,
          ),
        ),
        AppCard(
          child: Text(
            '현재 재고: ${product.totalQty}',
            style: AppTextStyles.body,
          ),
        ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  final String? imageUrl;

  const _Thumb({
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();

    if (url == null || url.isEmpty) {
      return const SizedBox(
        width: 72,
        height: 72,
        child: FlutterLogo(),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return const SizedBox(
            width: 72,
            height: 72,
            child: FlutterLogo(),
          );
        },
      ),
    );
  }
}