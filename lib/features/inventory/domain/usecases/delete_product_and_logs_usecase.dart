import '../repositories/inventory_repository.dart';

class DeleteProductAndLogsUseCase {
  final InventoryRepository repo;
  DeleteProductAndLogsUseCase(this.repo);

  Future<void> call(String productNo) => repo.deleteProductAndLogs(productNo: productNo);
}