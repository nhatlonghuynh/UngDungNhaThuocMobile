import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/models/thuoc_detail.dart';
import 'package:nhathuoc_mobilee/service/productservice.dart';

class ProductDetailController extends ChangeNotifier {
  final ProductService _service = ProductService();

  // State
  bool isLoading = true;
  String errorMessage = '';
  ThuocDetail? product;

  // State UI (Số lượng mua)
  int quantity = 1;

  // Hàm load dữ liệu
  Future<void> loadProduct(int id) async {
    isLoading = true;
    errorMessage = '';
    product = null;
    notifyListeners(); // Báo UI hiện vòng xoay loading
    print("--- BẮT ĐẦU LOAD CHI TIẾT ---");
    print("ID cần tìm: $id");
    final result = await _service.fetchProductDetail(id);

    print("Kết quả API trả về: $result");
    isLoading = false;
    if (result['success']) {
      product = result['data'];
    } else {
      errorMessage = result['message'];
    }
    notifyListeners(); // Báo UI vẽ lại dữ liệu hoặc lỗi
  }

  // Logic tăng giảm số lượng
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

  double get finalPrice {
    if (product == null) return 0;
    double price = product!.giaBan;
    if (product?.khuyenMai != null) {
      final km = product!.khuyenMai!;
      if (km.phanTramKM > 0) {
        price = price * (1 - km.phanTramKM / 100);
      } else if (km.tienGiam > 0) {
        price = price - km.tienGiam;
      }
    }
    if (price < 0) price = 0;
    return price < 0 ? 0 : price;
  }
}
