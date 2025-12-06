part of 'products_bloc.dart'; // ← مرة واحدة فقط

abstract class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object> get props => [];
}

class LoadProductsEvent extends ProductsEvent {}

class LoadProductsByCategoryEvent extends ProductsEvent {
  final int categoryId;

  const LoadProductsByCategoryEvent({required this.categoryId});

  @override
  List<Object> get props => [categoryId];
}

class LoadFeaturedProductsEvent extends ProductsEvent {}

class SearchProductsEvent extends ProductsEvent {
  final String query;

  const SearchProductsEvent({required this.query});

  @override
  List<Object> get props => [query];
}

class LoadProductByIdEvent extends ProductsEvent {
  final int productId;

  const LoadProductByIdEvent({required this.productId});

  @override
  List<Object> get props => [productId];
}