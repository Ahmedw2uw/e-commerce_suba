// lib/features/favorites/cubit/favorites_state.dart
import 'package:e_commerce/core/models/product_model.dart';

sealed class FavoritesState {
  const FavoritesState();
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<Product> favorites;
  const FavoritesLoaded(this.favorites);
}

class FavoritesError extends FavoritesState {
  final String message;
  const FavoritesError(this.message);
}