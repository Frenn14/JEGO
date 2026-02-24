import '../repositories/inventory_repository.dart';

class ReturnUseCase {
  final InventoryRepository repo;
  ReturnUseCase(this.repo);

  Future<void> call({
    required String uid,
    required String productNo,
    required int qty,
  }) {
    return repo.returnItem(uid: uid, productNo: productNo, qty: qty);
  }
}