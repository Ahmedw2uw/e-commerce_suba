import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:e_commerce/features/auth/models/product_model.dart';
import 'package:e_commerce/features/products/domain/repositories/products_repository.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final ProductsRepository productsRepository;

  ProductsBloc({required this.productsRepository}) : super(const ProductsState()) {
    on<LoadProductsEvent>(_onLoadProducts);
    on<LoadProductsByCategoryEvent>(_onLoadProductsByCategory);
    on<LoadFeaturedProductsEvent>(_onLoadFeaturedProducts);
    on<SearchProductsEvent>(_onSearchProducts);
    on<LoadProductByIdEvent>(_onLoadProductById);
  }

  Future<void> _onLoadProducts(
    LoadProductsEvent event,
    Emitter<ProductsState> emit,
  ) async {
    emit(state.copyWith(status: ProductsStatus.loading));
    
    try {
      final products = await productsRepository.getProducts();
      emit(state.copyWith(
        status: ProductsStatus.success,
        products: products,
        errorMessage: '',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadProductsByCategory(
    LoadProductsByCategoryEvent event,
    Emitter<ProductsState> emit,
  ) async {
    emit(state.copyWith(status: ProductsStatus.loading));
    
    try {
      final products = await productsRepository.getProductsByCategory(event.categoryId);
      emit(state.copyWith(
        status: ProductsStatus.success,
        products: products,
        errorMessage: '',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadFeaturedProducts(
    LoadFeaturedProductsEvent event,
    Emitter<ProductsState> emit,
  ) async {
    emit(state.copyWith(status: ProductsStatus.loading));
    
    try {
      final featuredProducts = await productsRepository.getFeaturedProducts();
      emit(state.copyWith(
        status: ProductsStatus.success,
        featuredProducts: featuredProducts,
        errorMessage: '',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSearchProducts(
    SearchProductsEvent event,
    Emitter<ProductsState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(state.copyWith(products: const [], searchQuery: ''));
      return;
    }

    emit(state.copyWith(
      status: ProductsStatus.loading,
      searchQuery: event.query,
    ));
    
    try {
      final products = await productsRepository.searchProducts(event.query);
      emit(state.copyWith(
        status: ProductsStatus.success,
        products: products,
        errorMessage: '',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadProductById(
    LoadProductByIdEvent event,
    Emitter<ProductsState> emit,
  ) async {
    emit(state.copyWith(status: ProductsStatus.loading));
    
    try {
      final product = await productsRepository.getProductById(event.productId);
      emit(state.copyWith(
        status: ProductsStatus.success,
        selectedProduct: product,
        errorMessage: '',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}