import '../repositories/inventory_repository.dart';

/// 반환값:
/// - null: 생성 성공
/// - productNo: 이미 존재(중복) → 그 제품 수정 페이지로 이동시키기 위함
class CreateProductUseCase {
  final InventoryRepository repo;
  CreateProductUseCase(this.repo);

  Future<String?> call({
    required String productNo,
    required String name,
    required int totalQty,
    required List<String> aliases,
    String? imageUrl,
  }) async {
    final exist = await repo.getProduct(productNo);
    if (exist != null) return productNo;

    await repo.createProduct(
      productNo: productNo,
      name: name,
      totalQty: totalQty,
      aliases: aliases,
      imageUrl: imageUrl,
    );

    return null;
  }
}