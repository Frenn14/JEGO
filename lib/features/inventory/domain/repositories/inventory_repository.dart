import '../entities/product_entity.dart';
import '../entities/transaction_entity.dart';

abstract class InventoryRepository {
  // Products
  Future<List<ProductEntity>> getProducts();
  Future<ProductEntity?> getProduct(String productNo);

  Future<void> createProduct({
    required String productNo,
    required String name,
    required int totalQty,
    required List<String> aliases,
    String? imageUrl,
  });

  Future<void> updateProduct({
    required String productNo, // immutable
    required String name,
    required int totalQty,
    required List<String> aliases,
    String? imageUrl,
  });

  Future<void> deleteProductAndLogs({
    required String productNo,
  });

  // User actions
  Future<void> checkout({
    required String uid,
    required String productNo,
    required int qty,
  });

  Future<void> returnItem({
    required String uid,
    required String productNo,
    required int qty,
  });

  Future<List<TransactionEntity>> getProductLogs({
    required String productNo,
    int limit,
  });

  Future<int> getMyBorrowedCount({
    required String uid,
    required String productNo,
  });
}