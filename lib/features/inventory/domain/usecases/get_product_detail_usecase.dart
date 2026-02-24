import '../entities/product_entity.dart';
import '../repositories/inventory_repository.dart';

class GetProductDetailUseCase {
  final InventoryRepository repo;
  GetProductDetailUseCase(this.repo);

  Future<ProductEntity?> call(String productNo) => repo.getProduct(productNo);
}