import '../../domain/entities/transaction_entity.dart';

class LoanModel extends TransactionEntity {
  const LoanModel({
    required super.id,
    required super.productNo,
    required super.uid,
    required super.type,
    required super.qty,
    required super.createdAt,
  });

  factory LoanModel.fromMap(String id, Map<String, dynamic> map) {
    return LoanModel(
      id: id,
      productNo: (map['productNo'] as String?) ?? '',
      uid: (map['uid'] as String?) ?? '',
      type: (map['type'] as String?) ?? 'checkout',
      qty: (map['qty'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(((map['createdAt'] as num?)?.toInt()) ?? 0),
    );
  }
}