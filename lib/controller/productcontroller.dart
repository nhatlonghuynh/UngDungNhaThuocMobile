import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/models/thuoc_detail.dart';
import 'package:nhathuoc_mobilee/service/productservice.dart';

class ProductDetailController extends ChangeNotifier {
  final ProductService _service = ProductService();

  // ---------------------------------------------------------------------------
  // STATE VARIABLES
  // ---------------------------------------------------------------------------
  ThuocDetail? product;
  bool isLoading = true;
  String errorMessage = '';

  // State UI
  int quantity = 1;

  // ---------------------------------------------------------------------------
  // PUBLIC METHODS
  // ---------------------------------------------------------------------------

  /// Tải chi tiết sản phẩm theo ID
  Future<void> loadProduct(int id) async {
    isLoading = true;
    errorMessage = '';
    product = null;
    quantity = 1; // Reset số lượng khi xem sản phẩm mới
    notifyListeners();

    try {
      final result = await _service.fetchProductDetail(id);
      if (result['success']) {
        product = result['data'];
      } else {
        errorMessage = result['message'];
      }
    } catch (e) {
      errorMessage = "Lỗi kết nối: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // UI ACTIONS
  // ---------------------------------------------------------------------------

  void increaseQuantity() {
    if (product != null && quantity < product!.soLuong) {
      quantity++;
      notifyListeners();
    }
  }

  void decreaseQuantity() {
    if (quantity > 1) {
      quantity--;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // GETTERS
  // ---------------------------------------------------------------------------

  /// Tính giá cuối cùng (sau khi trừ khuyến mãi)
  double get finalPrice {
    if (product == null) return 0;

    double price = product!.giaBan;
    final km = product!.khuyenMai;

    if (km != null) {
      if (km.phanTramKM > 0) {
        price = price * (1 - km.phanTramKM / 100);
      } else if (km.tienGiam > 0) {
        price = price - km.tienGiam;
      }
    }
    return price < 0 ? 0 : price;
  }
}
