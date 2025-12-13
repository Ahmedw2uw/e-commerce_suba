import 'package:e_commerce/features/auth/models/product_model.dart';

enum ProductsStatus { initial, loading, success, failure }

class ProductsState {
  final ProductsStatus status;
  final List<Product> featuredProducts;
  final List<Product> allProducts;
  final String? errorMessage;

  ProductsState({
    this.status = ProductsStatus.initial,
    this.featuredProducts = const [],
    this.allProducts = const [],
    this.errorMessage,
  });

  ProductsState copyWith({
    ProductsStatus? status,
    List<Product>? featuredProducts,
    List<Product>? allProducts,
    String? errorMessage,
  }) {
    return ProductsState(
      status: status ?? this.status,
      featuredProducts: featuredProducts ?? this.featuredProducts,
      allProducts: allProducts ?? this.allProducts,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
