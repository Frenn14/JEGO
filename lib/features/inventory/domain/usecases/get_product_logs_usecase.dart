import '../entities/transaction_entity.dart';
import '../repositories/inventory_repository.dart';

class GetProductLogsUseCase {
  final InventoryRepository repo;
  GetProductLogsUseCase(this.repo);

  Future<List<TransactionEntity>> call({
    required String productNo,
    int limit = 50,
  }) {
    return repo.getProductLogs(productNo: productNo, limit: limit);
  }
}