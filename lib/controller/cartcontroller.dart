import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/models/giohang.dart';
import 'package:nhathuoc_mobilee/service/cartservice.dart';

class CartController extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // 1. SINGLETON (Đảm bảo giỏ hàng đồng bộ toàn app)
  // ---------------------------------------------------------------------------
  static final CartController _instance = CartController._internal();
  factory CartController() => _instance;
  CartController._internal();

  final CartService _service = CartService();

  // ---------------------------------------------------------------------------
  // 2. STATE VARIABLES
  // ---------------------------------------------------------------------------
  List<GioHang> cartItems = [];
  bool isLoading = false;

  // ---------------------------------------------------------------------------
  // 3. PUBLIC METHODS (Tương tác dữ liệu)
  // ---------------------------------------------------------------------------

  /// Tải dữ liệu giỏ hàng từ API/Local
  Future<void> loadData() async {
    try {
      isLoading = true;
      notifyListeners();

      cartItems = await _service.getFullCartDetails();
    } catch (e) {
      print("Lỗi tải giỏ hàng: $e");
      cartItems = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Chọn hoặc bỏ chọn tất cả sản phẩm
  void toggleSelectAll(bool isSelected) {
    for (var item in cartItems) {
      item.isSelected = isSelected;
    }
    notifyListeners();
  }

  /// Cập nhật số lượng sản phẩm (+/-)
  Future<void> updateQuantity(int index, int change) async {
    if (index < 0 || index >= cartItems.length) return;

    int newQty = cartItems[index].soLuong + change;
    if (newQty > 0) {
      // Cập nhật UI ngay lập tức
      cartItems[index].soLuong = newQty;
      notifyListeners();

      // Cập nhật ngầm xuống Storage
      await _service.updateLocalCart(cartItems[index].maThuoc, change);
    }
  }

  /// Xóa sản phẩm khỏi giỏ
  Future<void> deleteItem(int index) async {
    if (index < 0 || index >= cartItems.length) return;

    int maThuoc = cartItems[index].maThuoc;

    // Xóa UI
    cartItems.removeAt(index);
    notifyListeners();

    // Xóa Storage
    await _service.removeLocalItem(maThuoc);
  }

  // ---------------------------------------------------------------------------
  // 4. COMPUTED PROPS (Tính toán cho UI)
  // ---------------------------------------------------------------------------

  /// Tổng tiền các món đang chọn
  double get totalPayment => _service.calculateTotal(cartItems);

  /// Kiểm tra có chọn tất cả không
  bool get isAllSelected =>
      cartItems.isNotEmpty && cartItems.every((e) => e.isSelected);

  /// Lấy danh sách các món đang chọn để thanh toán
  List<GioHang> get selectedItems =>
      cartItems.where((e) => e.isSelected).toList();
}
