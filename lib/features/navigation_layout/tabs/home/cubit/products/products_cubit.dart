import 'package:e_commerce/features/navigation_layout/tabs/home/cubit/products/products_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/features/auth/services/supabase_service.dart';

class ProductsCubit extends Cubit<ProductsState> {

  ProductsCubit() : super(ProductsState());

  Future<void> loadFeaturedProducts() async {
    emit(state.copyWith(status: ProductsStatus.loading));
    try {
      final products = await SupabaseService.getFeaturedProductsDirect();
      emit(state.copyWith(
        status: ProductsStatus.success,
        featuredProducts: products,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> loadAllProducts() async {
    emit(state.copyWith(status: ProductsStatus.loading));
    try {
      final products = await SupabaseService.getAllProducts();

      emit(state.copyWith(
        status: ProductsStatus.success,
        allProducts: products,   // ← صح
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
