import '../entities/product_entity.dart';
import '../repositories/inventory_repository.dart';

class GetProductsUseCase {
  final InventoryRepository repo;
  GetProductsUseCase(this.repo);

  Future<List<ProductEntity>> call() => repo.getProducts();
}