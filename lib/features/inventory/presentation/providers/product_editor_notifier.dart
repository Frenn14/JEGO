import 'package:flutter/material.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/create_product_usecase.dart';
import '../../domain/usecases/delete_product_and_logs_usecase.dart';
import '../../domain/usecases/get_product_detail_usecase.dart';
import '../../domain/usecases/update_product_usecase.dart';

class ProductEditorNotifier extends ChangeNotifier {
  final GetProductDetailUseCase getDetailUseCase;
  final CreateProductUseCase createProductUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final DeleteProductAndLogsUseCase deleteProductAndLogsUseCase;

  ProductEditorNotifier({
    required this.getDetailUseCase,
    required this.createProductUseCase,
    required this.updateProductUseCase,
    required this.deleteProductAndLogsUseCase,
  });

  bool _isLoading = false;
  String? _error;
  ProductEntity? _product;

  bool get isLoading => _isLoading;
  String? get error => _error;
  ProductEntity? get product => _product;

  Future<void> load(String productNo) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _product = await getDetailUseCase(productNo);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// return: null이면 성공 / productNo면 "중복"
  Future<String?> createNew({
    required String productNo,
    required String name,
    required int totalQty,
    required List<String> aliases,
    required String? imageUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      return await createProductUseCase(
        productNo: productNo,
        name: name,
        totalQty: totalQty,
        aliases: aliases,
        imageUrl: imageUrl,
      );
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> update({
    required String productNo,
    required String name,
    required int totalQty,
    required List<String> aliases,
    required String? imageUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await updateProductUseCase(
        productNo: productNo,
        name: name,
        totalQty: totalQty,
        aliases: aliases,
        imageUrl: imageUrl,
      );
      _product = await getDetailUseCase(productNo);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProductAndLogs(String productNo) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await deleteProductAndLogsUseCase(productNo);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}