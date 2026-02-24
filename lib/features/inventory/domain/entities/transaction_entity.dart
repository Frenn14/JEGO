class TransactionEntity {
  final String id;
  final String productNo;
  final String uid;
  final String type; // checkout / return
  final int qty;
  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.productNo,
    required this.uid,
    required this.type,
    required this.qty,
    required this.createdAt,
  });
}