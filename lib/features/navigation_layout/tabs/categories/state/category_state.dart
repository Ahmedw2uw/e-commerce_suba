// lib/features/navigation_layout/tabs/categories/state/category_state.dart

import 'package:e_commerce/features/auth/models/category_model.dart';
import 'package:e_commerce/features/auth/models/product_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' hide Category;

@immutable
abstract class CategoryState extends Equatable {
  const CategoryState();
  
  @override
  List<Object> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<Category> categories;
  final int selectedIndex;
  final List<Product> products;
  
  const CategoryLoaded({
    required this.categories,
    required this.selectedIndex,
    required this.products,
  });
  
  @override
  List<Object> get props => [categories, selectedIndex, products];
}

class CategoryError extends CategoryState {
  final String message;
  
  const CategoryError(this.message);
  
  @override
  List<Object> get props => [message];
}