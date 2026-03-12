// ⚠️ 아래는 기존 파일 구조 유지하면서 핵심 버그만 고친 버전(전체 교체 권장)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/spacing_system.dart';
import '../../../../../core/theme/text_system.dart';
import '../../../../../core/widgets/app_bottom_nav.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/app_scaffold.dart';
import '../../../../auth/presentation/providers/auth_notifier.dart';
import '../../providers/product_usage_notifier.dart';

class ProductUsagePage extends StatefulWidget {
  final String productNo;
  const ProductUsagePage({super.key, required this.productNo});

  @override
  State createState() => _ProductUsagePageState();
}

class _ProductUsagePageState extends State<ProductUsagePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  late final TextEditingController _qtyCtrl;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _qtyCtrl = TextEditingController(text: '1');

    Future.microtask(() async {
      final auth = context.read<AuthNotifier>();
      final uid = auth.uid; // ✅ 핵심 수정
      if (uid == null) return;

      await context.read<ProductUsageNotifier>().load(
        uid: uid,
        productNo: widget.productNo,
      );
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    final uid = auth.uid; // ✅ 핵심 수정
    final usage = context.watch<ProductUsageNotifier>();
    final p = usage.product;

    if (uid == null) {
      return AppScaffold(
        title: '사용/반납',
        body: AppCard(child: Text('로그인이 필요합니다.', style: AppTextStyles.body)),
      );
    }

    final currentQty = p?.totalQty ?? 0;
    final myBorrowed = usage.myBorrowed;

    final canCheckout = !usage.isLoading && currentQty > 0;
    final canReturn = !usage.isLoading && myBorrowed > 0;

    final progress = currentQty <= 0 ? 0.0 : 1.0;

    return AppScaffold(
      title: '사용/반납',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (usage.error != null)
            AppCard(child: Text('에러: ${usage.error}', style: AppTextStyles.body)),

          AppCard(
            child: Row(
              children: [
                _Thumb(imageUrl: p?.imageUrl),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p?.name ?? '로딩...', style: AppTextStyles.title),
                      const SizedBox(height: AppSpacing.xs),
                      Text('현재 재고: $currentQty', style: AppTextStyles.body),
                      const SizedBox(height: AppSpacing.xs),
                      LinearProgressIndicator(value: progress),
                      const SizedBox(height: AppSpacing.xs),
                      Text('제품 ID: ${widget.productNo}', style: AppTextStyles.body),
                      const SizedBox(height: AppSpacing.xs),
                      Text('내가 빌린 수량: $myBorrowed', style: AppTextStyles.body),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          AppCard(
            child: TextField(
              controller: _qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: '수량'),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: canCheckout ? '사용' : '사용 불가',
                  onPressed: canCheckout
                      ? () async {
                    final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 0;
                    if (qty <= 0) return;
                    await context.read<ProductUsageNotifier>().checkout(
                      uid: uid,
                      productNo: widget.productNo,
                      qty: qty,
                    );
                  }
                      : null, // ✅ 진짜 비활성
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  text: canReturn ? '반납' : '반납 불가',
                  onPressed: canReturn
                      ? () async {
                    final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 0;
                    if (qty <= 0) return;
                    if (qty > myBorrowed) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('반납 수량이 내가 빌린 수량보다 큽니다.')),
                      );
                      return;
                    }
                    await context.read<ProductUsageNotifier>().returnItem(
                      uid: uid,
                      productNo: widget.productNo,
                      qty: qty,
                    );
                  }
                      : null, // ✅ 진짜 비활성
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          TabBar(
            controller: _tab,
            tabs: const [Tab(text: '로그'), Tab(text: 'Info')],
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: const [_LogsTab(), _InfoTab()],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
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
    final logs = usage.logs;
    if (logs.isEmpty) {
      return Center(child: Text('로그가 없습니다.', style: AppTextStyles.body));
    }
    return ListView.separated(
      itemCount: logs.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, i) {
        final l = logs[i];
        final typeLabel = l.type == 'checkout' ? '사용' : '반납';
        return AppCard(
          child: Text('$typeLabel x${l.qty} | uid:${l.uid} | ${l.createdAt}',
              style: AppTextStyles.body),
        );
      },
    );
  }
}

class _InfoTab extends StatelessWidget {
  const _InfoTab();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProductUsageNotifier>().product;
    if (p == null) {
      return Center(child: Text('정보를 불러오는 중...', style: AppTextStyles.body));
    }
    return ListView(
      children: [
        AppCard(child: Text('상품번호: ${p.productNo}', style: AppTextStyles.body)),
        AppCard(child: Text('이름: ${p.name}', style: AppTextStyles.body)),
        AppCard(child: Text('별칭: ${p.aliases.join(", ")}', style: AppTextStyles.body)),
        AppCard(child: Text('이미지 URL: ${p.imageUrl ?? "-"}', style: AppTextStyles.body)),
        AppCard(child: Text('현재 재고: ${p.totalQty}', style: AppTextStyles.body)),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  final String? imageUrl;
  const _Thumb({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) {
      return const SizedBox(height: 72, width: 72, child: FlutterLogo());
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        height: 72,
        width: 72,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox(height: 72, width: 72, child: FlutterLogo()),
      ),
    );
  }
}