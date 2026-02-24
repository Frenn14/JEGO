import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/loan_model.dart';

class InventoryFirestoreDataSource {
  final FirebaseFirestore firestore;
  InventoryFirestoreDataSource(this.firestore);

  CollectionReference<Map<String, dynamic>> get _products => firestore.collection('products');
  CollectionReference<Map<String, dynamic>> get _logs => firestore.collection('product_logs');

  Future<List<ProductModel>> getProducts() async {
    final snap = await _products.orderBy('updatedAt', descending: true).get();
    return snap.docs.map((d) => ProductModel.fromMap(d.id, d.data())).toList();
  }

  Future<ProductModel?> getProduct(String productNo) async {
    final doc = await _products.doc(productNo).get();
    if (!doc.exists) return null;
    return ProductModel.fromMap(doc.id, doc.data()!);
  }

  Future<bool> existsProduct(String productNo) async {
    final doc = await _products.doc(productNo).get();
    return doc.exists;
  }

  Future<void> createProduct({
    required String productNo,
    required String name,
    required int totalQty,
    required List<String> aliases,
    String? imageUrl,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _products.doc(productNo).set({
      'name': name,
      'aliases': aliases,
      'imageUrl': imageUrl,
      'totalQty': totalQty,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  Future<void> updateProduct({
    required String productNo,
    required String name,
    required int totalQty,
    required List<String> aliases,
    String? imageUrl,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _products.doc(productNo).update({
      'name': name,
      'aliases': aliases,
      'imageUrl': imageUrl,
      'totalQty': totalQty,
      'updatedAt': now,
    });
  }

  /// ✅ 삭제 시 로그도 삭제 (Functions 없이: 클라이언트 배치 삭제)
  /// - 한 번에 500개 제한이 있으니 pagination으로 반복
  Future<void> deleteProductAndLogs(String productNo) async {
    // 1) 제품 삭제
    await _products.doc(productNo).delete();

    // 2) 로그 배치 삭제 (productNo로 조회)
    while (true) {
      final q = await _logs.where('productNo', isEqualTo: productNo).limit(450).get();
      if (q.docs.isEmpty) break;

      final batch = firestore.batch();
      for (final d in q.docs) {
        batch.delete(d.reference);
      }
      await batch.commit();
    }
  }

  /// ✅ 유저 사용(재고 감소 + 로그)
  Future<void> checkout({
    required String uid,
    required String productNo,
    required int qty,
  }) async {
    final prodRef = _products.doc(productNo);
    final now = DateTime.now().millisecondsSinceEpoch;

    await firestore.runTransaction((tx) async {
      final prodSnap = await tx.get(prodRef);
      if (!prodSnap.exists) throw Exception('제품이 존재하지 않습니다.');

      final data = prodSnap.data()!;
      final current = (data['totalQty'] as num?)?.toInt() ?? 0;
      if (qty <= 0) throw Exception('수량이 올바르지 않습니다.');
      if (current < qty) throw Exception('재고가 부족합니다.');

      tx.update(prodRef, {
        'totalQty': current - qty,
        'updatedAt': now,
      });

      final logRef = _logs.doc();
      tx.set(logRef, {
        'productNo': productNo,
        'uid': uid,
        'type': 'checkout',
        'qty': qty,
        'createdAt': now,
      });
    });
  }

  /// ✅ 유저 반납(재고 증가 + 로그)
  Future<void> returnItem({
    required String uid,
    required String productNo,
    required int qty,
  }) async {
    final prodRef = _products.doc(productNo);
    final now = DateTime.now().millisecondsSinceEpoch;

    await firestore.runTransaction((tx) async {
      final prodSnap = await tx.get(prodRef);
      if (!prodSnap.exists) throw Exception('제품이 존재하지 않습니다.');

      if (qty <= 0) throw Exception('수량이 올바르지 않습니다.');

      final data = prodSnap.data()!;
      final current = (data['totalQty'] as num?)?.toInt() ?? 0;

      tx.update(prodRef, {
        'totalQty': current + qty,
        'updatedAt': now,
      });

      final logRef = _logs.doc();
      tx.set(logRef, {
        'productNo': productNo,
        'uid': uid,
        'type': 'return',
        'qty': qty,
        'createdAt': now,
      });
    });
  }

  Future<List<LoanModel>> getProductLogs({
    required String productNo,
    int limit = 50,
  }) async {
    final snap = await _logs
        .where('productNo', isEqualTo: productNo)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snap.docs.map((d) => LoanModel.fromMap(d.id, d.data())).toList();
  }

  /// ✅ 내 “현재 빌린 수량” = checkout 합 - return 합
  Future<int> getMyBorrowedCount({
    required String uid,
    required String productNo,
  }) async {
    final snap = await _logs
        .where('productNo', isEqualTo: productNo)
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(500)
        .get();

    int outSum = 0;
    int retSum = 0;

    for (final d in snap.docs) {
      final m = d.data();
      final type = (m['type'] as String?) ?? '';
      final qty = (m['qty'] as num?)?.toInt() ?? 0;
      if (type == 'checkout') outSum += qty;
      if (type == 'return') retSum += qty;
    }
    final v = outSum - retSum;
    return v < 0 ? 0 : v;
  }
}