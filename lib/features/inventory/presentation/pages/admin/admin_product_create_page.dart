import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/spacing_system.dart';
import '../../../../../core/theme/text_system.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/app_scaffold.dart';
import '../../../../../core/widgets/app_textfield.dart';
import '../../providers/product_editor_notifier.dart';
import 'admin_product_edit_page.dart';

class AdminProductCreatePage extends StatefulWidget {
  const AdminProductCreatePage({super.key});

  @override
  State<AdminProductCreatePage> createState() => _AdminProductCreatePageState();
}

class _AdminProductCreatePageState extends State<AdminProductCreatePage> {
  late final TextEditingController _productNo;
  late final TextEditingController _name;
  late final TextEditingController _qty;
  late final TextEditingController _aliases;
  late final TextEditingController _imageUrl;

  @override
  void initState() {
    super.initState();
    _productNo = TextEditingController();
    _name = TextEditingController();
    _qty = TextEditingController(text: '0');
    _aliases = TextEditingController();
    _imageUrl = TextEditingController();
  }

  @override
  void dispose() {
    _productNo.dispose();
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

    return AppScaffold(
      title: '새 제품 추가',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (editor.error != null) AppCard(child: Text('에러: ${editor.error}', style: AppTextStyles.body)),
          AppTextField(hint: '상품번호(필수, 유일)', controller: _productNo),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(hint: '제품명(필수)', controller: _name),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(hint: '초기 재고 수량', controller: _qty, keyboardType: TextInputType.number),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(hint: '별칭(쉼표로 구분)', controller: _aliases),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(hint: '이미지 URL(선택)', controller: _imageUrl, keyboardType: TextInputType.url),
          const SizedBox(height: AppSpacing.lg),

          AppButton(
            text: editor.isLoading ? '처리 중...' : '추가',
            onPressed: editor.isLoading
                ? () {}
                : () async {
              final productNo = _productNo.text.trim();
              final name = _name.text.trim();
              final qty = int.tryParse(_qty.text.trim()) ?? -1;
              final aliases = _parseAliases(_aliases.text);
              final imageUrl = _imageUrl.text.trim().isEmpty ? null : _imageUrl.text.trim();

              if (productNo.isEmpty || name.isEmpty || qty < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('상품번호/제품명/수량을 확인해줘')),
                );
                return;
              }

              final existsNo = await context.read<ProductEditorNotifier>().createNew(
                productNo: productNo,
                name: name,
                totalQty: qty,
                aliases: aliases,
                imageUrl: imageUrl,
              );

              if (!context.mounted) return;

              if (existsNo != null) {
                // ✅ 중복이면 안내 후 해당 제품 수정 페이지로 이동
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('이미 존재하는 상품번호입니다. 해당 제품 페이지로 이동합니다.')),
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => AdminProductEditPage(productNo: existsNo)),
                );
                return;
              }

              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}