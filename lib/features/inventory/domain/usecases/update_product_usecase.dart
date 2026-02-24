import '../repositories/inventory_repository.dart';

class UpdateProductUseCase {
  final InventoryRepository repo;
  UpdateProductUseCase(this.repo);

  Future<void> call({
    required String productNo, // immutable
    required String name,
    required int totalQty,
    required List<String> aliases,
    String? imageUrl,
  }) {
    return repo.updateProduct(
      productNo: productNo,
      name: name,
      totalQty: totalQty,
      aliases: aliases,
      imageUrl: imageUrl,
    );
  }
}