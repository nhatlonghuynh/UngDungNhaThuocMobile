import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/models/thuoc_detail.dart';
import 'package:nhathuoc_mobilee/service/productservice.dart';
import 'package:nhathuoc_mobilee/api/productapi.dart';

class ProductDetailController extends ChangeNotifier {
  final ProductService _service = ProductService(repo: ProductRepository());

  ThuocDetail? product;
  bool isLoading = true;
  String errorMessage = '';
  int quantity = 1;

  Future<void> loadProduct(int id) async {
    isLoading = true;
    errorMessage = '';
    product = null;
    quantity = 1;
    notifyListeners();

    try {
      debugPrint("📱 [Detail] Loading ID: $id");
      final result = await _service.fetchProductDetail(id);

      if (result['success']) {
        product = result['data'];
        debugPrint("✅ [Detail] Loaded: ${product?.tenThuoc}");
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

  void increaseQuantity() {
    if (product != null && quantity < product!.soLuong) {
      quantity++;
      notifyListeners();
    } else {
      debugPrint("⚠️ [Detail] Max stock reached");
    }
  }

  void decreaseQuantity() {
    if (quantity > 1) {
      quantity--;
      notifyListeners();
    }
  }

  // Dùng Service tính toán để đảm bảo logic khuyến mãi nhất quán
  double get finalPrice {
    if (product == null) return 0;
    return ProductService.getDiscountedPrice(product);
  }

  // Getter tổng tiền (Giá x Số lượng)
  double get totalPrice => finalPrice * quantity;
}
