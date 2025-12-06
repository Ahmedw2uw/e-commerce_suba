// lib/features/cart/presentation/bloc/cart_state.dart
part of 'cart_bloc.dart';

enum CartStatus { initial, loading, success, failure }

class CartState extends Equatable {
  final CartStatus status;
  final List<CartItemEntity> cartItems;
  final String errorMessage;
  final double totalAmount;

  const CartState({
    this.status = CartStatus.initial,
    this.cartItems = const [],
    this.errorMessage = '',
    this.totalAmount = 0.0,
  });

  int get totalItems => cartItems.fold(0, (sum, item) => sum + item.quantity);

  CartState copyWith({
    CartStatus? status,
    List<CartItemEntity>? cartItems,
    String? errorMessage,
    double? totalAmount,
  }) {
    return CartState(
      status: status ?? this.status,
      cartItems: cartItems ?? this.cartItems,
      errorMessage: errorMessage ?? this.errorMessage,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }

  @override
  List<Object?> get props => [status, cartItems, errorMessage, totalAmount];
}