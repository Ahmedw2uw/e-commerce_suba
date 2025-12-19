import 'package:e_commerce/features/navigation_layout/tabs/favorite/data/repositories/favorites_repository.dart';
import 'package:e_commerce/core/models/product_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository _favoritesRepository;

  FavoritesCubit(this._favoritesRepository) : super(const FavoritesState());

  Future<void> loadFavorites() async {
    emit(state.copyWith(status: FavoritesStatus.loading));
    try {
      final favoriteProducts = await _favoritesRepository.getFavoriteProducts();
      final favoriteIds = favoriteProducts.map((product) => product.id).toSet();
      emit(state.copyWith(
        items: favoriteProducts,
        ids: favoriteIds,
        status: FavoritesStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FavoritesStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> toggleFavorite(int productId) async {
    // Optimistic update
    final isFavorite = state.ids.contains(productId);
    final newIds = Set<int>.from(state.ids);
    if (isFavorite) {
      newIds.remove(productId);
    } else {
      newIds.add(productId);
    }
    
    // We update the IDs immediately for UI responsiveness
    // Note: The items list won't be updated correctly until reload, 
    // but for the heart icon, IDs are enough.
    emit(state.copyWith(ids: newIds));

    try {
      await _favoritesRepository.toggleFavorite(productId);
      // Reload to ensure consistency and update items list
      await loadFavorites();
    } catch (e) {
      // Revert on failure
      emit(state.copyWith(
        ids: state.ids, // This might be tricky, better to reload
        errorMessage: 'Failed to toggle favorite',
      ));
      await loadFavorites();
    }
  }

  bool isFavorite(int productId) {
    return state.ids.contains(productId);
  }
}
