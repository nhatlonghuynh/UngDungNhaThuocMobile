import 'dart:convert';
import 'package:flutter/foundation.dart'; // DebugPrint
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:nhathuoc_mobilee/UI/common/constants/api_constants.dart'; // Dùng chung constant
import 'package:nhathuoc_mobilee/models/cartitemlocal.dart';
import 'package:nhathuoc_mobilee/models/giohang.dart';
import 'package:nhathuoc_mobilee/models/thuoc.dart';

class CartManager extends ChangeNotifier {
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal();

  List<CartItemLocal> _localItems = [];
  final String _storageKey = 'my_cart_data';

  // Getter số lượng (cho Badge trên icon giỏ hàng)
  int get cartCount => _localItems.fold(0, (sum, item) => sum + item.soLuong);

  // ---------------------------------------------------------
  // A. LOCAL STORAGE HANDLING
  // ---------------------------------------------------------

  Future<void> addToCart(int maThuoc, int quantity) async {
    await _loadFromPrefs(); // Đảm bảo data mới nhất

    final index = _localItems.indexWhere((e) => e.maThuoc == maThuoc);

    if (index >= 0) {
      _localItems[index].soLuong += quantity;
      debugPrint("🛒 [Cart] Update Item: ID $maThuoc (+ $quantity)");
    } else {
      _localItems.add(CartItemLocal(maThuoc: maThuoc, soLuong: quantity));
      debugPrint("🛒 [Cart] Add New: ID $maThuoc (Qty: $quantity)");
    }

    await _saveToPrefs();
  }

  Future<void> removeFromCart(int maThuoc) async {
    _localItems.removeWhere((item) => item.maThuoc == maThuoc);
    await _saveToPrefs();
    debugPrint("🗑️ [Cart] Removed ID: $maThuoc");
    notifyListeners();
  }

  Future<void> updateQuantity(int maThuoc, int newQuantity) async {
    final index = _localItems.indexWhere((e) => e.maThuoc == maThuoc);
    if (index == -1) return;

    if (newQuantity > 0) {
      _localItems[index].soLuong = newQuantity;
    } else {
      _localItems.removeAt(index); // Xóa nếu số lượng = 0
    }
    await _saveToPrefs();
  }

  Future<void> clearCart() async {
    _localItems.clear();
    await _saveToPrefs();
    debugPrint("🧹 [Cart] Cleared all items");
  }

  // --- Helpers ---

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(_localItems.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, jsonData);
  }

  Future<void> _loadFromPrefs() async {
    if (_localItems.isNotEmpty) return; // Cache đơn giản

    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);

    if (data != null) {
      try {
        final jsonList = jsonDecode(data) as List<dynamic>;
        _localItems = jsonList.map((e) => CartItemLocal.fromJson(e)).toList();
      } catch (e) {
        debugPrint("❌ [Cart] Load Error: $e");
      }
    }
  }

  // ---------------------------------------------------------
  // B. SYNC SERVER (Lấy thông tin chi tiết: Tên, Giá, Ảnh)
  // ---------------------------------------------------------

  Future<List<GioHang>> fetchCartDetails() async {
    await _loadFromPrefs();
    if (_localItems.isEmpty) return [];

    final listIDs = _localItems.map((e) => e.maThuoc).toList();

    // Sử dụng ApiConstants để tránh hardcode IP
    final url = Uri.parse('${ApiConstants.baseUrl}/thuoc/get_cart');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"ids": listIDs}),
      );

      if (response.statusCode != 200) {
        debugPrint("❌ [Cart] Server Error: ${response.statusCode}");
        return [];
      }

      // Decode UTF8
      final bodyString = utf8.decode(response.bodyBytes);
      final jsonRaw = jsonDecode(bodyString) as List;
      final listThuoc = jsonRaw.map((e) => Thuoc.fromJson(e)).toList();

      debugPrint("✅ [Cart] Synced ${listThuoc.length} items from server");
      return _mergeLocalAndServer(listThuoc);
    } catch (e) {
      debugPrint("❌ [Cart] API Error: $e");
      return [];
    }
  }

  List<GioHang> _mergeLocalAndServer(List<Thuoc> listThuoc) {
    List<GioHang> result = [];

    for (var thuoc in listThuoc) {
      // Tìm số lượng tương ứng trong Local
      final localItem = _localItems.firstWhere(
        (item) => item.maThuoc == thuoc.maThuoc,
        orElse: () => CartItemLocal(maThuoc: -1, soLuong: 0),
      );

      if (localItem.maThuoc != -1) {
        result.add(
          GioHang(
            maThuoc: thuoc.maThuoc,
            anhURL: thuoc.anhURL,
            donGia: thuoc.donGia,
            tenThuoc: thuoc.tenThuoc,
            soLuong: localItem.soLuong,
            // Có thể thêm field 'donVi' nếu Model Thuoc có
          ),
        );
      }
    }
    return result;
  }
}
