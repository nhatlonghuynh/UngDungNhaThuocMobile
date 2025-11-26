import 'dart:convert';
import 'package:nhathuoc_mobilee/api/cartapi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nhathuoc_mobilee/models/cartitemlocal.dart';
import 'package:nhathuoc_mobilee/models/giohang.dart';
import 'package:nhathuoc_mobilee/models/thuoc.dart'; // Import Repo ở trên

class CartService {
  final CartRepository _repository = CartRepository();

  // --- PHẦN 1: XỬ LÝ LOCAL STORAGE ---

  // Lấy danh sách thô từ máy
  Future<List<CartItemLocal>> getLocalItems() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('my_cart_data');
    if (data != null) {
      List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((e) => CartItemLocal.fromJson(e)).toList();
    }
    return [];
  }

  // Lưu danh sách thô xuống máy
  Future<void> saveLocalItems(List<CartItemLocal> items) async {
    final prefs = await SharedPreferences.getInstance();
    String data = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString('my_cart_data', data);
  }

  // Logic thêm/cập nhật số lượng
  Future<void> updateLocalCart(int maThuoc, int quantityChange) async {
    List<CartItemLocal> items = await getLocalItems();
    final index = items.indexWhere((e) => e.maThuoc == maThuoc);

    if (index >= 0) {
      // Đã có -> cộng dồn
      int newQty = items[index].soLuong + quantityChange;
      if (newQty <= 0) {
        items.removeAt(index); // Xóa nếu về 0
      } else {
        items[index].soLuong = newQty;
      }
    } else if (quantityChange > 0) {
      // Chưa có -> thêm mới
      items.add(CartItemLocal(maThuoc: maThuoc, soLuong: quantityChange));
    }

    await saveLocalItems(items);
  }

  // Xóa hẳn item
  Future<void> removeLocalItem(int maThuoc) async {
    List<CartItemLocal> items = await getLocalItems();
    items.removeWhere((item) => item.maThuoc == maThuoc);
    await saveLocalItems(items);
  }

  // --- PHẦN 2: LOGIC GHÉP DỮ LIỆU (Business Logic chính) ---

  Future<List<GioHang>> getFullCartDetails() async {
    // 1. Lấy Local
    List<CartItemLocal> localItems = await getLocalItems();
    if (localItems.isEmpty) return [];

    // 2. Lấy danh sách ID
    List<int> ids = localItems.map((e) => e.maThuoc).toList();

    // 3. Gọi Repo lấy thông tin thuốc từ Server
    try {
      List<Thuoc> serverInfo = await _repository.getProductsByIds(ids);

      // 4. Ghép dữ liệu (Merge Logic)
      List<GioHang> result = [];
      for (var thuoc in serverInfo) {
        var localItem = localItems.firstWhere(
          (l) => l.maThuoc == thuoc.maThuoc,
          orElse: () => CartItemLocal(maThuoc: -1, soLuong: 1),
        );

        result.add(
          GioHang(
            maThuoc: thuoc.maThuoc,
            tenThuoc: thuoc.tenThuoc,
            anhURL: thuoc.anhURL,
            donGia: thuoc.donGia,
            soLuong: localItem.soLuong,
            isSelected: false, // Mặc định chưa chọn
          ),
        );
      }
      return result;
    } catch (e) {
      print("Lỗi Service: $e");
      return [];
    }
  }

  // Logic tính tổng tiền
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
