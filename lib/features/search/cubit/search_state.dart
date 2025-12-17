part of 'search_cubit.dart';

abstract class SearchState {
  const SearchState();
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchSuccess extends SearchState {
  final List<Product> products; // ⬅️ Product بدل ProductModel
  final String query;

  const SearchSuccess({
    required this.products,
    required this.query,
  });
}

class SearchEmpty extends SearchState {
  final String query;

  const SearchEmpty(this.query);
}

class SearchError extends SearchState {
  final String message;

  const SearchError({required this.message});
}