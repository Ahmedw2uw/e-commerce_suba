// lib/features/cart/presentation/bloc/cart_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:e_commerce/features/auth/models/product_model.dart';
import 'package:equatable/equatable.dart';
import 'package:e_commerce/features/cart/domain/entities/cart_item_entity.dart';
import 'package:e_commerce/features/cart/domain/repositories/cart_repository.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository cartRepository;

  CartBloc({required this.cartRepository}) : super(const CartState()) {
    on<LoadCartEvent>(_onLoadCart);
    on<AddToCartEvent>(_onAddToCart);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<UpdateCartItemQuantityEvent>(_onUpdateQuantity);
    on<ClearCartEvent>(_onClearCart);
  }

  Future<void> _onLoadCart(
    LoadCartEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(state.copyWith(status: CartStatus.loading));
    
    try {
      final cartItems = await cartRepository.getCartItems();
      final totalAmount = _calculateTotalAmount(cartItems);
      
      emit(state.copyWith(
        status: CartStatus.success,
        cartItems: cartItems,
        totalAmount: totalAmount,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CartStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAddToCart(
    AddToCartEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      await cartRepository.addToCart(
        product: event.product,
        quantity: event.quantity,
      );
      
      // إعادة تحميل السلة
      add(LoadCartEvent());
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to add item: ${e.toString()}',
      ));
    }
  }

  Future<void> _onRemoveFromCart(
    RemoveFromCartEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      await cartRepository.removeFromCart(event.cartItemId);
      add(LoadCartEvent());
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to remove item: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateQuantity(
    UpdateCartItemQuantityEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      await cartRepository.updateQuantity(
        cartItemId: event.cartItemId,
        newQuantity: event.newQuantity,
      );
      add(LoadCartEvent());
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to update quantity: ${e.toString()}',
      ));
    }
  }

  Future<void> _onClearCart(
    ClearCartEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      await cartRepository.clearCart();
      emit(const CartState(status: CartStatus.success));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to clear cart: ${e.toString()}',
      ));
    }
  }

  double _calculateTotalAmount(List<CartItemEntity> items) {
    return items.fold(
      0.0,
      (total, item) => total + item.totalPrice,
    );
  }
}