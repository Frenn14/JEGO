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
      _all = await getProductsUseCase() as List<ProductEntity>;
      _items = searchProductsUseCase(
        source: _all,
        query: _query,
      ).cast<ProductEntity>();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setQuery(String query) {
    _query = query;
    _items = searchProductsUseCase(
      source: _all,
      query: _query,
    ).cast<ProductEntity>();
    notifyListeners();
  }
}