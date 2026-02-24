import '../entities/product_entity.dart';

class SearchProductsUseCase {
  List<ProductEntity> call({
    required List<ProductEntity> source,
    required String query,
  }) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return List.of(source);

    return source.where((p) {
      final name = p.name.toLowerCase();
      final no = p.productNo.toLowerCase();
      final aliases = p.aliases.join(' ').toLowerCase();
      return name.contains(q) || no.contains(q) || aliases.contains(q);
    }).toList();
  }
}