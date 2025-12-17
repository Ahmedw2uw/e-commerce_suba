part of 'products_bloc.dart';

enum ProductsStatus { initial, loading, success, failure }

class ProductsState extends Equatable {
  final ProductsStatus status;

  final List<Product> products;      // المعروض
  final List<Product> allProducts;   // 🔹 إضافة جديدة (الأصل)

  final List<Product> featuredProducts;
  final Product? selectedProduct;

  final String errorMessage;
  final String searchQuery;

  const ProductsState({
    this.status = ProductsStatus.initial,
    this.products = const [],
    this.allProducts = const [], // 🔹 إضافة
    this.featuredProducts = const [],
    this.selectedProduct,
    this.errorMessage = '',
    this.searchQuery = '',
  });

  ProductsState copyWith({
    ProductsStatus? status,
    List<Product>? products,
    List<Product>? allProducts, // 🔹 إضافة
    List<Product>? featuredProducts,
    Product? selectedProduct,
    String? errorMessage,
    String? searchQuery,
  }) {
    return ProductsState(
      status: status ?? this.status,
      products: products ?? this.products,
      allProducts: allProducts ?? this.allProducts, // 🔹 إضافة
      featuredProducts: featuredProducts ?? this.featuredProducts,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        status,
        products,
        allProducts, // 🔹 إضافة
        featuredProducts,
        selectedProduct,
        errorMessage,
        searchQuery,
      ];
}
