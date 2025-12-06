part of 'products_bloc.dart'; // ← مرة واحدة فقط

enum ProductsStatus { initial, loading, success, failure }

class ProductsState extends Equatable {
  final ProductsStatus status;
  final List<Product> products;
  final List<Product> featuredProducts;
  final Product? selectedProduct;
  final String errorMessage;
  final String searchQuery;

  const ProductsState({
    this.status = ProductsStatus.initial,
    this.products = const [],
    this.featuredProducts = const [],
    this.selectedProduct,
    this.errorMessage = '',
    this.searchQuery = '',
  });

  ProductsState copyWith({
    ProductsStatus? status,
    List<Product>? products,
    List<Product>? featuredProducts,
    Product? selectedProduct,
    String? errorMessage,
    String? searchQuery,
  }) {
    return ProductsState(
      status: status ?? this.status,
      products: products ?? this.products,
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
        featuredProducts,
        selectedProduct,
        errorMessage,
        searchQuery,
      ];
}