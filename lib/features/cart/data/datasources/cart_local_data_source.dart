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
      print('🔄 محاولة تهيئة صندوق Hive...');
      
      if (!Hive.isBoxOpen(_cartBox)) {
        print('📦 فتح صندوق Hive جديد');
        _box = await Hive.openBox<Map>(_cartBox);
      } else {
        print('📦 استخدام صندوق Hive مفتوح بالفعل');
        _box = Hive.box<Map>(_cartBox);
      }
      
      _isInitialized = true;
      print('✅ تم تهيئة صندوق Hive بنجاح');
    } catch (e) {
      print('❌ خطأ في تهيئة Hive: $e');
      rethrow;
    }
  }

  @override
  Future<List<CartItemModel>> getCartItems() async {
    await _ensureInitialized();
    
    try {
      final items = _box.values.toList();
      print('📦 جاري تحميل ${items.length} عنصر من Hive');
      
      return items.map((item) {
        return CartItemModel.fromJson(Map<String, dynamic>.from(item));
      }).toList();
    } catch (e) {
      print('❌ خطأ في تحميل العناصر من Hive: $e');
      return [];
    }
  }

  @override
  Future<void> saveCartItems(List<CartItemModel> items) async {
    await _ensureInitialized();
    
    try {
      await _box.clear();
      print('🗑️ تم مسح الصندوق القديم');
      
      for (final item in items) {
        await _box.put(item.id, item.toJson());
      }
      print('✅ تم حفظ ${items.length} عنصر في Hive');
    } catch (e) {
      print('❌ خطأ في حفظ العناصر في Hive: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearCart() async {
    await _ensureInitialized();
    
    try {
      await _box.clear();
      print('✅ تم مسح السلة من Hive');
    } catch (e) {
      print('❌ خطأ في مسح السلة من Hive: $e');
      rethrow;
    }
  }
}