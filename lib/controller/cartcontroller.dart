import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/models/giohang.dart';
import 'package:nhathuoc_mobilee/service/cartservice.dart';

class CartController extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // Singleton: dùng chung 1 instance trong app
  // ---------------------------------------------------------------------------
  static final CartController _instance = CartController._internal();
  factory CartController() => _instance;
  CartController._internal();

  final CartService _service = CartService();

  // ---------------------------------------------------------------------------
  // STATE UI
  // ---------------------------------------------------------------------------
  List<GioHang> cartItems = [];
  bool isLoading = false;

  // ---------------------------------------------------------------------------
  // 1. Tải dữ liệu giỏ hàng từ Service
  // ---------------------------------------------------------------------------
  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    cartItems = await _service.getFullCartDetails();

    isLoading = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // 2. Chọn tất cả / Bỏ chọn tất cả
  // ---------------------------------------------------------------------------
  void toggleSelectAll(bool isSelected) {
    for (var item in cartItems) {
      item.isSelected = isSelected;
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // 3. Thay đổi số lượng (+/-)
  // ---------------------------------------------------------------------------
  Future<void> updateQuantity(int index, int change) async {
    int newQty = cartItems[index].soLuong + change;
    if (newQty > 0) {
      cartItems[index].soLuong = newQty;
      notifyListeners();

      // Cập nhật dữ liệu cục bộ (local)
      await _service.updateLocalCart(cartItems[index].maThuoc, change);
    }
  }

  // ---------------------------------------------------------------------------
  // 4. Xóa sản phẩm khỏi giỏ
  // ---------------------------------------------------------------------------
  Future<void> deleteItem(int index) async {
    int maThuoc = cartItems[index].maThuoc;

    // Xóa khỏi UI
    cartItems.removeAt(index);
    notifyListeners();

    // Xóa khỏi Service/local storage
    await _service.removeLocalItem(maThuoc);
  }

  // ---------------------------------------------------------------------------
  // 5. Getter tính toán
  // ---------------------------------------------------------------------------
  double get totalPayment => _service.calculateTotal(cartItems);

  bool get isAllSelected =>
      cartItems.isNotEmpty && cartItems.every((e) => e.isSelected);

  List<GioHang> get selectedItems =>
      cartItems.where((e) => e.isSelected).toList();
}
