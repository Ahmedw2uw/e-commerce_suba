import 'package:e_commerce/features/navigation_layout/tabs/favorite/data/repositories/favorites_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoritesCubit extends Cubit<List<int>> {
  // نخزن فقط product IDs
  FavoritesCubit(FavoritesRepositoryImpl favoritesRepositoryImpl) : super([]);

  void toggleFavorite(int productId) {
    final newList = List<int>.from(state);
    
    if (newList.contains(productId)) {
      // موجود - أمسحه
      newList.remove(productId);
    } else {
      // مش موجود - حطه
      newList.add(productId);
    }
    
    emit(newList);
    print('❤️ Favorites updated: $newList');
  }

  bool isFavorite(int productId) {
    return state.contains(productId);
  }

  List<int> getFavorites() {
    return state;
  }
}