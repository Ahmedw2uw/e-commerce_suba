import 'dart:async';
import 'package:e_commerce/core/models/product_model.dart';
import 'package:e_commerce/features/search/repositories/search_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepository _searchRepository;
  Timer? _debounceTimer;

  SearchCubit({required SearchRepository searchRepository})
      : _searchRepository = searchRepository,
        super(SearchInitial());

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    try {
      final products = await _searchRepository.searchProducts(query);
      
      if (products.isEmpty) {
        emit(SearchEmpty(query));
      } else {
        emit(SearchSuccess(products: products, query: query));
      }
    } catch (e) {
      emit(SearchError(message: 'Search error: $e'));
    }
  }

  void searchInstant(String query) {
    if (query.trim().isEmpty) {
      emit(SearchInitial());
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      search(query);
    });
  }

  void clearSearch() {
    emit(SearchInitial());
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}