import '../../domain/entities/product_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/inventory_firestore_datasource.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryFirestoreDataSource ds;
  InventoryRepositoryImpl(this.ds);

  @override
  Future<List<ProductEntity>> getProducts() => ds.getProducts();

  @override
  Future<ProductEntity?> getProduct(String productNo) => ds.getProduct(productNo);

  @override
  Future<void> createProduct({
    required String productNo,
    required String name,
    required int totalQty,
    required List<String> aliases,
    String? imageUrl,
  }) =>
      ds.createProduct(
        productNo: productNo,
        name: name,
        totalQty: totalQty,
        aliases: aliases,
        imageUrl: imageUrl,
      );

  @override
  Future<void> updateProduct({
    required String productNo,
    required String name,
    required int totalQty,
    required List<String> aliases,
    String? imageUrl,
  }) =>
      ds.updateProduct(
        productNo: productNo,
        name: name,
        totalQty: totalQty,
        aliases: aliases,
        imageUrl: imageUrl,
      );

  @override
  Future<void> deleteProductAndLogs({required String productNo}) => ds.deleteProductAndLogs(productNo);

  @override
  Future<void> checkout({required String uid, required String productNo, required int qty}) =>
      ds.checkout(uid: uid, productNo: productNo, qty: qty);

  @override
  Future<void> returnItem({required String uid, required String productNo, required int qty}) =>
      ds.returnItem(uid: uid, productNo: productNo, qty: qty);

  @override
  Future<List<TransactionEntity>> getProductLogs({required String productNo, int limit = 50}) =>
      ds.getProductLogs(productNo: productNo, limit: limit);

  @override
  Future<int> getMyBorrowedCount({required String uid, required String productNo}) =>
      ds.getMyBorrowedCount(uid: uid, productNo: productNo);
}