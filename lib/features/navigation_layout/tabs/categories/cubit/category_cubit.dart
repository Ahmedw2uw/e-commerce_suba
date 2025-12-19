import 'package:e_commerce/core/models/category_model.dart';
import 'package:e_commerce/features/navigation_layout/tabs/categories/repositories/category_repository.dart';
import 'package:e_commerce/features/navigation_layout/tabs/categories/cubit/category_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository _repository;
  
  CategoryCubit(this._repository) : super(CategoryInitial());

  List<Category> _categories = [];

  Future<void> loadCategories() async {
    emit(CategoryLoading());
    try {
      // Fetch all categories
      _categories = await _repository.fetchCategories();
      
      if (_categories.isEmpty) {
        emit(CategoryError('No categories found'));
        return;
      }

      // Fetch products for the first category (default)
      final products = await _repository.fetchProductsByCategory(
        _categories.first.id,
      );

      emit(CategoryLoaded(
        categories: _categories,
        selectedIndex: 0,
        products: products,
      ));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> changeCategory(int index) async {
    if (index < 0 || index >= _categories.length) return;
    
    emit(CategoryLoading());
    try {
      
      final products = await _repository.fetchProductsByCategory(
        _categories[index].id,
      );

      emit(CategoryLoaded(
        categories: _categories,
        selectedIndex: index,
        products: products,
      ));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> refresh() async {
    await loadCategories();
  }
}