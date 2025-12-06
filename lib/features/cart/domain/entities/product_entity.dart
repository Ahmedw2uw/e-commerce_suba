// lib/features/products/domain/entities/product_entity.dart
import 'package:e_commerce/features/cart/domain/entities/category_entity.dart';
import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final List<String> images;
  final int stockQuantity;
  final String? color;
  final String? size;
  final CategoryEntity category;
  final double? rating;
  final int? reviewCount;
  final bool isFeatured;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.images,
    required this.stockQuantity,
    this.color,
    this.size,
    required this.category,
    this.rating,
    this.reviewCount,
    this.isFeatured = false,
    this.createdAt,
    this.updatedAt,
  });

  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  double get finalPrice => discountPrice ?? price;

  double get discountPercentage {
    if (!hasDiscount) return 0;
    return ((price - discountPrice!) / price) * 100;
  }

  bool get isOutOfStock => stockQuantity <= 0;

  bool get isLowStock => stockQuantity > 0 && stockQuantity <= 10;

  ProductEntity copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? discountPrice,
    List<String>? images,
    int? stockQuantity,
    String? color,
    String? size,
    CategoryEntity? category,
    double? rating,
    int? reviewCount,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      images: images ?? this.images,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      color: color ?? this.color,
      size: size ?? this.size,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        price,
        discountPrice,
        images,
        stockQuantity,
        category.id,
        isFeatured,
      ];
}