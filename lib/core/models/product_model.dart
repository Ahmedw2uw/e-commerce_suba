import 'package:e_commerce/core/models/category_model.dart';

class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String? size;
  final int stockQuantity;
  final String? color;
  final int categoryId;
  final List<String> images;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Category? category;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.size,
    required this.stockQuantity,
    this.color,
    required this.categoryId,
    required this.images,
    this.createdAt,
    this.updatedAt,
    this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    Category? category;
    if (json['category'] != null && json['category'] is Map) {
      try {
        category = Category.fromJson(json['category']);
      } catch (e) {
        category = null;
      }
    }

    List<String> imagesList = [];
    if (json['images'] != null && json['images'] is List) {
      imagesList = List<String>.from(
        json['images'].map((item) => item.toString()),
      );
    }

    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      size: json['size'],
      stockQuantity: json['stock_quantity'] ?? 0,
      color: json['color'],
      categoryId: json['category_id'] ?? 0,
      images: imagesList,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      category: category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'size': size,
      'stock_quantity': stockQuantity,
      'color': color,
      'category_id': categoryId,
      'images': images,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'category': category?.toJson(),
    };
  }
}
