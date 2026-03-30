import 'package:flutter/material.dart';

import '../../domain/entities/product_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/checkout_usecase.dart';
import '../../domain/usecases/get_product_detail_usecase.dart';
import '../../domain/usecases/get_product_logs_usecase.dart';
import '../../domain/usecases/return_usecase.dart';

class ProductUsageNotifier extends ChangeNotifier {
  final GetProductDetailUseCase getDetailUseCase;
  final GetProductLogsUseCase getLogsUseCase;
  final CheckoutUseCase checkoutUseCase;
  final ReturnUseCase returnUseCase;

  ProductUsageNotifier({
    required this.getDetailUseCase,
    required this.getLogsUseCase,
    required this.checkoutUseCase,
    required this.returnUseCase,
  });

  bool _isLoading = false;
  String? _error;
  ProductEntity? _product;
  List<TransactionEntity> _logs = [];
  int _myBorrowed = 0;

  bool get isLoading => _isLoading;
  String? get error => _error;
  ProductEntity? get product => _product;
  List<TransactionEntity> get logs => _logs;
  int get myBorrowed => _myBorrowed;

  Future<void> load({
    required String uid,
    required String productNo,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _product = await getDetailUseCase(productNo) as ProductEntity;
      _logs = (await getLogsUseCase(
        productNo: productNo,
        limit: 50,
      ))
          .cast<TransactionEntity>();
      _myBorrowed = _calcMyBorrowed(uid, _logs);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int _calcMyBorrowed(String uid, List<TransactionEntity> logs) {
    int outSum = 0;
    int returnSum = 0;

    for (final log in logs) {
      if (log.uid != uid) continue;
      if (log.type == 'checkout') outSum += log.qty;
      if (log.type == 'return') returnSum += log.qty;
    }

    final borrowed = outSum - returnSum;
    return borrowed < 0 ? 0 : borrowed;
  }

  Future<void> checkout({
    required String uid,
    required String productNo,
    required int qty,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await checkoutUseCase(
        uid: uid,
        productNo: productNo,
        qty: qty,
      );
      await load(uid: uid, productNo: productNo);
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> returnItem({
    required String uid,
    required String productNo,
    required int qty,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await returnUseCase(
        uid: uid,
        productNo: productNo,
        qty: qty,
      );
      await load(uid: uid, productNo: productNo);
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}