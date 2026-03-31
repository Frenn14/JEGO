import 'package:flutter/material.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/search_products_usecase.dart';

class InventoryListNotifier extends ChangeNotifier {
  final GetProductsUseCase getProductsUseCase;
  final SearchProductsUseCase searchProductsUseCase;

  InventoryListNotifier({
    required this.getProductsUseCase,
    required this.searchProductsUseCase,
  });

  bool _isLoading = false;
  String? _error;

  List<ProductEntity> _all = [];
  List<ProductEntity> _items = [];
  String _query = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ProductEntity> get items => _items;
  String get query => _query;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _all = await getProductsUseCase();
      _items = searchProductsUseCase(source: _all, query: _query);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setQuery(String q) {
    _query = q;
    _items = searchProductsUseCase(source: _all, query: _query);
    notifyListeners();
  }
}