import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/spacing_system.dart';
import '../../../../../core/theme/text_system.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/app_scaffold.dart';
import '../../../../../core/widgets/app_textfield.dart';
import '../../providers/product_editor_notifier.dart';

class AdminProductEditPage extends StatefulWidget {
  final String productNo;
  const AdminProductEditPage({super.key, required this.productNo});

  @override
  State<AdminProductEditPage> createState() => _AdminProductEditPageState();
}

class _AdminProductEditPageState extends State<AdminProductEditPage> {
  late final TextEditingController _name;
  late final TextEditingController _qty;
  late final TextEditingController _aliases;
  late final TextEditingController _imageUrl;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _qty = TextEditingController();
    _aliases = TextEditingController();
    _imageUrl = TextEditingController();

    Future.microtask(() async {
      await context.read<ProductEditorNotifier>().load(widget.productNo);
      final p = context.read<ProductEditorNotifier>().product;
      if (p != null) {
        _name.text = p.name;
        _qty.text = p.totalQty.toString();
        _aliases.text = p.aliases.join(', ');
        _imageUrl.text = p.imageUrl ?? '';
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _qty.dispose();
    _aliases.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  List<String> _parseAliases(String raw) =>
      raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  @override
  Widget build(BuildContext context) {
    final editor = context.watch<ProductEditorNotifier>();
    final p = editor.product;

    return AppScaffold(
      title: '제품 수정',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (editor.error != null) AppCard(child: Text('에러: ${editor.error}', style: AppTextStyles.body)),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('상품번호(수정 불가)', style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.xs),
                Text(widget.productNo, style: AppTextStyles.body),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          AppTextField(hint: '제품명', controller: _name),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(hint: '재고 수량', controller: _qty, keyboardType: TextInputType.number),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(hint: '별칭(쉼표)', controller: _aliases),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(hint: '이미지 URL', controller: _imageUrl, keyboardType: TextInputType.url),
          const SizedBox(height: AppSpacing.lg),

          AppButton(
            text: editor.isLoading ? '저장 중...' : '저장',
            onPressed: editor.isLoading
                ? () {}
                : () async {
              final name = _name.text.trim();
              final qty = int.tryParse(_qty.text.trim()) ?? -1;
              if (name.isEmpty || qty < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('제품명/수량을 확인해줘')),
                );
                return;
              }

              await context.read<ProductEditorNotifier>().update(
                productNo: widget.productNo,
                name: name,
                totalQty: qty,
                aliases: _parseAliases(_aliases.text),
                imageUrl: _imageUrl.text.trim().isEmpty ? null : _imageUrl.text.trim(),
              );

              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('저장 완료')),
              );
            },
          ),

          const SizedBox(height: AppSpacing.md),

          // ✅ 삭제 버튼 + 확인
          AppButton(
            text: editor.isLoading ? '처리 중...' : '삭제',
            onPressed: editor.isLoading
                ? () {}
                : () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('삭제 확인'),
                  content: const Text('이 제품과 관련 로그가 모두 삭제됩니다. 진행할까요?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제')),
                  ],
                ),
              );

              if (ok != true) return;

              await context.read<ProductEditorNotifier>().deleteProductAndLogs(widget.productNo);
              if (!context.mounted) return;

              Navigator.pop(context); // 리스트로
            },
          ),

          if (p == null && !editor.isLoading)
            AppCard(child: Text('제품 정보를 불러오지 못했습니다.', style: AppTextStyles.body)),
        ],
      ),
    );
  }
}