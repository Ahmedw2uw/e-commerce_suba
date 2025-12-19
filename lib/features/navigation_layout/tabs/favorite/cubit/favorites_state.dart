part of 'favorites_cubit.dart';

enum FavoritesStatus { initial, loading, success, failure }

class FavoritesState {
  final List<Product> items;
  final Set<int> ids;
  final FavoritesStatus status;
  final String? errorMessage;

  const FavoritesState({
    this.items = const [],
    this.ids = const {},
    this.status = FavoritesStatus.initial,
    this.errorMessage,
  });

  FavoritesState copyWith({
    List<Product>? items,
    Set<int>? ids,
    FavoritesStatus? status,
    String? errorMessage,
  }) {
    return FavoritesState(
      items: items ?? this.items,
      ids: ids ?? this.ids,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}
