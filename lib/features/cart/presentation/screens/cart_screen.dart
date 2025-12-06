// lib/features/cart/presentation/screens/cart_screen.dart
import 'package:e_commerce/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:e_commerce/features/cart/presentation/widget/cart_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static const String routeName = '/cart_screen';

  @override
  Widget build(BuildContext context) {
    print('🛒 === فتح شاشة السلة ===');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              print('🛒 حالة السلة: ${state.cartItems.length} منتجات');
              
              if (state.cartItems.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    print('🗑️ طلب مسح السلة');
                    context.read<CartBloc>().add(ClearCartEvent());
                  },
                  tooltip: 'Clear Cart',
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) {
          if (state.status == CartStatus.failure) {
            print('❌ خطأ في السلة: ${state.errorMessage}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
          
          if (state.status == CartStatus.success) {
            print('✅ حالة السلة محدثة: ${state.cartItems.length} منتج، المجموع: ${state.totalAmount}');
          }
        },
        builder: (context, state) {
          print('🛒 بناء واجهة السلة - الحالة: ${state.status}');
          print('   المنتجات: ${state.cartItems.length}');
          print('   المجموع: ${state.totalAmount}');
          print('   خطأ: ${state.errorMessage}');

          if (state.status == CartStatus.loading) {
            print('⏳ جاري تحميل السلة...');
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جاري تحميل السلة...'),
                ],
              ),
            );
          }

          if (state.cartItems.isEmpty) {
            print('🛒 السلة فارغة');
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'سلة التسوق فارغة',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  Text(
                    'أضف منتجات للبدء',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          print('🛒 عرض ${state.cartItems.length} منتج في السلة');
          
          return Column(
            children: [
              // قائمة المنتجات
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = state.cartItems[index];
                    print('   المنتج ${index + 1}: ${item.product.name} × ${item.quantity}');
                    
                    return CartItemWidget(
                      item: item,
                      onRemove: () {
                        print("`🗑️: ${item.product.name}`");
                        context.read<CartBloc>().add(
                          RemoveFromCartEvent(cartItemId: item.id),
                        );
                      },
                      onQuantityChanged: (newQuantity) {
                        print("🔄  ${item.product.name} $newQuantity");
                        context.read<CartBloc>().add(
                          UpdateCartItemQuantityEvent(
                            cartItemId: item.id,
                            newQuantity: newQuantity,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // قسم الإجمالي والدفع
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'عدد المنتجات:',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '${state.totalItems}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'المجموع الكلي:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'ج.م ${state.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          print('💰 الانتقال للدفع');
                          // TODO: الانتقال لشاشة الدفع
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'إتمام الشراء',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}