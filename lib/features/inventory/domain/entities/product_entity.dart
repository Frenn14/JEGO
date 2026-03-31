class ProductEntity {
  final String productNo; // docId
  final String name;
  final List<String> aliases;
  final String? imageUrl;
  final int totalQty;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductEntity({
    required this.productNo,
    required this.name,
    required this.aliases,
    required this.imageUrl,
    required this.totalQty,
    required this.createdAt,
    required this.updatedAt,
  });
}