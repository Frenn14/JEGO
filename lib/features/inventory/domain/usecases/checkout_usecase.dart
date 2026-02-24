import '../repositories/inventory_repository.dart';

class CheckoutUseCase {
  final InventoryRepository repo;
  CheckoutUseCase(this.repo);

  Future<void> call({
    required String uid,
    required String productNo,
    required int qty,
  }) {
    return repo.checkout(uid: uid, productNo: productNo, qty: qty);
  }
}