import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:e_commerce/features/navigation_layout/tabs/home/model/product_model.dart';
import 'package:e_commerce/features/products/domain/repositories/products_repository.dart';

part 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final ProductsRepository productsRepository;

  ProductsCubit({required this.productsRepository}) : super(const ProductsState());

  // ================= Load All Products =================
  Future<void> loadProducts() async {
    emit(state.copyWith(status: ProductsStatus.loading));

    try {
      final products = await productsRepository.getProducts();
      emit(state.copyWith(
        status: ProductsStatus.success,
        products: products,
        allProducts: products,
        errorMessage: '',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  // ================= Load By Category =================
  Future<void> loadProductsByCategory(int categoryId) async {
    emit(state.copyWith(status: ProductsStatus.loading));

    try {
      final products = await productsRepository.getProductsByCategory(categoryId);
      emit(state.copyWith(
        status: ProductsStatus.success,
        products: products,
        allProducts: products,
        errorMessage: '',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  // ================= Featured Products =================
  Future<void> loadFeaturedProducts() async {
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

  // ================= Search Products =================
  void searchProducts(String query) {
    final lowerQuery = query.toLowerCase();

    if (lowerQuery.isEmpty) {
      emit(state.copyWith(
        products: state.allProducts,
        searchQuery: '',
      ));
      return;
    }

    final filteredProducts = state.allProducts.where((product) {
      return product.name.toLowerCase().contains(lowerQuery);
    }).toList();

    emit(state.copyWith(
      products: filteredProducts,
      searchQuery: query,
    ));
  }

  // ================= Load Product By ID =================
  Future<void> loadProductById(int productId) async {
    emit(state.copyWith(status: ProductsStatus.loading));

    try {
      final product = await productsRepository.getProductById(productId);
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
