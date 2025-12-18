// lib/features/navigation_layout/tabs/categories/cubit/category_cubit.dart

import 'package:e_commerce/features/auth/models/category_model.dart';
import 'package:e_commerce/features/navigation_layout/tabs/categories/repostry/category_repository.dart';
import 'package:e_commerce/features/navigation_layout/tabs/categories/cubit/category_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository _repository;
  
  CategoryCubit(this._repository) : super(CategoryInitial());

  List<Category> _categories = [];

  Future<void> loadCategories() async {
    emit(CategoryLoading());
    try {
      // جلب كل التصنيفات
      _categories = await _repository.fetchCategories();
      
      if (_categories.isEmpty) {
        emit(CategoryError('No categories found'));
        return;
      }

      // جلب منتجات التصنيف الأول (الافتراضي)
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