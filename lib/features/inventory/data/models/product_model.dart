import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.productNo,
    required super.name,
    required super.aliases,
    required super.imageUrl,
    required super.totalQty,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProductModel.fromMap(String productNo, Map<String, dynamic> map) {
    return ProductModel(
      productNo: productNo,
      name: (map['name'] as String?) ?? '',
      aliases: ((map['aliases'] as List?) ?? []).map((e) => e.toString()).toList(),
      imageUrl: map['imageUrl'] as String?,
      totalQty: (map['totalQty'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(((map['createdAt'] as num?)?.toInt()) ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(((map['updatedAt'] as num?)?.toInt()) ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'aliases': aliases,
      'imageUrl': imageUrl,
      'totalQty': totalQty,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }
}