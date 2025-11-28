import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/models/giohang.dart';
import 'package:nhathuoc_mobilee/service/cartservice.dart'; // Import đúng Service

class CartController extends ChangeNotifier {
  // Singleton
  static final CartController _instance = CartController._internal();
  factory CartController() => _instance;
  CartController._internal();

  final CartService _service = CartService();

  List<GioHang> cartItems = [];
  bool isLoading = false;

  // --- ACTIONS ---

  Future<void> loadData() async {
    try {
      isLoading = true;
      // notifyListeners(); // Có thể comment dòng này để tránh nháy màn hình không cần thiết

      debugPrint("🛒 [Controller] Bắt đầu load giỏ hàng...");
      cartItems = await _service.getFullCartDetails();
      debugPrint("🛒 [Controller] Load xong: ${cartItems.length} sản phẩm");
    } catch (e) {
      debugPrint("❌ [Controller] Lỗi load data: $e");
      cartItems = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void toggleSelectAll(bool isSelected) {
    for (var item in cartItems) {
      item.isSelected = isSelected;
    }
    notifyListeners();
  }
  // Mở file controller/cartcontroller.dart và thêm hàm này vào:

  /// Đảo ngược trạng thái chọn của 1 item
  void toggleItem(int index) {
    if (index >= 0 && index < cartItems.length) {
      cartItems[index].isSelected = !cartItems[index].isSelected;
      notifyListeners(); // Quan trọng: Báo hiệu để cập nhật Tổng tiền
    }
  }

  // Optimistic UI: Update UI -> Update Local sau
  Future<void> updateQuantity(int index, int change) async {
    if (index < 0 || index >= cartItems.length) return;

    int currentQty = cartItems[index].soLuong;
    int newQty = currentQty + change;
    int maThuoc = cartItems[index].maThuoc;

    if (newQty > 0) {
      // 1. Cập nhật UI ngay
      cartItems[index].soLuong = newQty;
      notifyListeners();
      debugPrint("⚡ [Optimistic] Đã cập nhật UI item $maThuoc thành $newQty");

      // 2. Lưu xuống Local (Chạy ngầm)
      await _service.updateLocalCart(maThuoc, change);
    }
  }

  Future<void> deleteItem(int index) async {
    if (index < 0 || index >= cartItems.length) return;
    int maThuoc = cartItems[index].maThuoc;

    // 1. Xóa UI ngay
    cartItems.removeAt(index);
    notifyListeners();
    debugPrint("⚡ [Optimistic] Đã xóa item khỏi UI");

    // 2. Xóa Local (Chạy ngầm)
    await _service.removeLocalItem(maThuoc);
  }

  // --- GETTERS ---
  double get totalPayment => _service.calculateTotal(cartItems);

  bool get isAllSelected =>
      cartItems.isNotEmpty && cartItems.every((e) => e.isSelected);

  List<GioHang> get selectedItems =>
      cartItems.where((e) => e.isSelected).toList();
}
