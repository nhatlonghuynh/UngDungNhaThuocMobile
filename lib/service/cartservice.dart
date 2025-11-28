import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:nhathuoc_mobilee/api/cartapi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nhathuoc_mobilee/models/cartitemlocal.dart';
import 'package:nhathuoc_mobilee/models/giohang.dart';
import 'package:nhathuoc_mobilee/models/thuoc.dart';

class CartService {
  final CartRepository _repository = CartRepository();
  final String _storageKey = 'my_cart_data';

  // --- LOCAL STORAGE ---

  Future<List<CartItemLocal>> getLocalItems() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString(_storageKey);
    if (data != null) {
      List<dynamic> jsonList = jsonDecode(data);
      // debugPrint('💾 [CartService] Đọc Local: $jsonList');
      return jsonList.map((e) => CartItemLocal.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> saveLocalItems(List<CartItemLocal> items) async {
    final prefs = await SharedPreferences.getInstance();
    String data = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, data);
    debugPrint('💾 [CartService] Đã lưu Local: $data');
  }

  Future<void> updateLocalCart(int maThuoc, int quantityChange) async {
    List<CartItemLocal> items = await getLocalItems();
    final index = items.indexWhere((e) => e.maThuoc == maThuoc);

    if (index >= 0) {
      int newQty = items[index].soLuong + quantityChange;
      if (newQty <= 0) {
        items.removeAt(index);
        debugPrint('💾 [CartService] Xóa item $maThuoc vì số lượng <= 0');
      } else {
        items[index].soLuong = newQty;
      }
    } else if (quantityChange > 0) {
      items.add(CartItemLocal(maThuoc: maThuoc, soLuong: quantityChange));
      debugPrint('💾 [CartService] Thêm mới item $maThuoc');
    }

    await saveLocalItems(items);
  }

  Future<void> removeLocalItem(int maThuoc) async {
    List<CartItemLocal> items = await getLocalItems();
    items.removeWhere((item) => item.maThuoc == maThuoc);
    await saveLocalItems(items);
    debugPrint('💾 [CartService] Đã xóa item $maThuoc khỏi Local');
  }

  // --- MERGE LOGIC ---

  Future<List<GioHang>> getFullCartDetails() async {
    // 1. Lấy Local
    List<CartItemLocal> localItems = await getLocalItems();
    if (localItems.isEmpty) return [];

    // 2. Lấy ID gửi lên Server
    List<int> ids = localItems.map((e) => e.maThuoc).toList();

    try {
      // 3. Lấy thông tin chi tiết (Tên, Giá, Ảnh)
      List<Thuoc> serverInfo = await _repository.getProductsByIds(ids);

      // 4. Ghép (Merge)
      List<GioHang> result = [];
      for (var thuoc in serverInfo) {
        // Tìm số lượng tương ứng trong Local
        var localItem = localItems.firstWhere(
          (l) => l.maThuoc == thuoc.maThuoc,
          orElse: () => CartItemLocal(maThuoc: -1, soLuong: 1),
        );

        if (localItem.maThuoc != -1) {
             result.add(GioHang(
            maThuoc: thuoc.maThuoc,
            tenThuoc: thuoc.tenThuoc,
            anhURL: thuoc.anhURL,
            donGia: thuoc.donGia,
            soLuong: localItem.soLuong, // Lấy số lượng từ máy người dùng
            isSelected: false,
          ));
        }
      }
      return result;
    } catch (e) {
      debugPrint("❌ [CartService] Merge Lỗi: $e");
      return [];
    }
  }

  double calculateTotal(List<GioHang> items) {
    double total = 0;
    for (var item in items) {
      if (item.isSelected) {
        total += item.tongTien;
      }
    }
    return total;
  }
}