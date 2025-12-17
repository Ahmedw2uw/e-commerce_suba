import 'package:e_commerce/features/cart/data/models/cart_item_model.dart';
import 'package:hive/hive.dart';

abstract class CartLocalDataSource {
  Future<void> saveCartItems(List<CartItemModel> items);
  Future<List<CartItemModel>> getCartItems();
  Future<void> clearCart();
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  static const String _cartBox = 'cart_box';
  late Box<Map> _box;
  bool _isInitialized = false;

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    
    try {
      
      if (!Hive.isBoxOpen(_cartBox)) {
        _box = await Hive.openBox<Map>(_cartBox);
      } else {
        _box = Hive.box<Map>(_cartBox);
      }
      
      _isInitialized = true;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CartItemModel>> getCartItems() async {
    await _ensureInitialized();
    
    try {
      final items = _box.values.toList();
      
      return items.map((item) {
        return CartItemModel.fromJson(Map<String, dynamic>.from(item));
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveCartItems(List<CartItemModel> items) async {
    await _ensureInitialized();
    
    try {
      await _box.clear();
      
      for (final item in items) {
        await _box.put(item.id, item.toJson());
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> clearCart() async {
    await _ensureInitialized();
    
    try {
      await _box.clear();
    } catch (e) {
      rethrow;
    }
  }
}