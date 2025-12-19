import 'dart:async';
import 'package:e_commerce/core/utilits/app_lottie.dart';
import 'package:e_commerce/core/models/product_model.dart';
import 'package:e_commerce/features/products/data/datasource/products_remote_data_source.dart';
import 'package:e_commerce/features/products/presentation/widget/product_card.dart';
import 'package:e_commerce/features/search/view/custom_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class SearchCubit extends Cubit<SearchState> {
  final ProductsRemoteDataSourceImpl productsRemoteDataSource;
  Timer? _debounce;

  SearchCubit({required this.productsRemoteDataSource})
      : super(SearchInitial());

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    try {
      final products = await productsRemoteDataSource.searchProducts(query);

      if (products.isEmpty) {
        emit(SearchEmpty(query));
      } else {
        emit(SearchSuccess(products: products, query: query));
      }
    } catch (e) {
      emit(SearchError('Search error: $e'));
    }
  }

  void searchInstant(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isNotEmpty) {
        search(query);
      } else {
        emit(SearchInitial());
      }
    });
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchSuccess extends SearchState {
  final List<Product> products;
  final String query;

  SearchSuccess({required this.products, required this.query});
}

class SearchEmpty extends SearchState {
  final String query;
  SearchEmpty(this.query);
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}

class SearchResultsScreen extends StatefulWidget {
  final String initialQuery;

  const SearchResultsScreen({
    super.key,
    required this.initialQuery,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  late SearchCubit _searchCubit;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _searchFocusNode = FocusNode();
    
    _searchCubit = SearchCubit(
      productsRemoteDataSource: ProductsRemoteDataSourceImpl(),
    );

    if (widget.initialQuery.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchCubit.search(widget.initialQuery);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _searchCubit,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: CustomSearchField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: (query) {
              _searchCubit.searchInstant(query);
            },
            onSubmitted: (query) {
              if (query.trim().isNotEmpty) {
                _searchCubit.search(query);
              }
            },
          ),
          automaticallyImplyLeading: false,
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {

        if (state is SearchInitial) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Type to search for a product',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        if (state is SearchLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(AppLottie.loading),
                const SizedBox(height: 16),
                const Text('Searching...'),
              ],
            ),
          );
        }

        if (state is SearchError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    state.message,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    context.read<SearchCubit>().search(_searchController.text);
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        if (state is SearchEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No results for "${state.query}"',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    _searchController.clear();
                    _searchFocusNode.requestFocus();
                  },
                  child: const Text('Try another word'),
                ),
              ],
            ),
          );
        }

        if (state is SearchSuccess) {
          return _buildResultsList(state);
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildResultsList(SearchSuccess state) {
    return Column(
      children: [
        // Results counter
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Row(
            children: [
              Text(
                '${state.products.length} results for "${state.query}"',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (state.products.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.sort),
                  onPressed: () {
                    // TODO: Add sorting logic
                  },
                ),
            ],
          ),
        ),
        
        // Product List
        Expanded(
          child: state.products.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                    
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: state.products.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final product = state.products[index];
                    return ProductCard(
                      product: product,
                      isFavorite: false, // TODO: Fetch favorite status
                      onFavorite: () async {
                        // TODO: Call SupabaseService.toggleFavorite
                      },
                      onAdd: () {
                        // TODO: Add to cart
                      },
                      onTap: () {
                        // TODO: Navigation to product page
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}