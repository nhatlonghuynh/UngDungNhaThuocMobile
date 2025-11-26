import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/models/thuoc.dart';
import 'package:nhathuoc_mobilee/service/productservice.dart';

class HomeController extends ChangeNotifier {
  final ProductService _service = ProductService();

  List<Thuoc> products = [];
  bool isLoading = true;
  String errorMessage = '';

  // Khởi tạo là tải dữ liệu ngay
  HomeController() {
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      products = await _service.getProducts();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> onSearch(String keyword) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      if (keyword.isEmpty) {
        // Nếu xóa hết chữ thì load lại tất cả sản phẩm
        products = await _service.getProducts();
      } else {
        // Nếu có chữ thì tìm theo tên hoặc công dụng
        products = await _service.searchProductByNameOrUse(keyword);
      }
    } catch (e) {
      errorMessage = "Không tìm thấy kết quả phù hợp";
      products = []; // Xóa danh sách cũ nếu lỗi
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // --- Wrapper để UI gọi các hàm tính toán từ Service ---
  bool checkPromo(Thuoc t) => _service.hasPromotion(t);
  double finalPrice(Thuoc t) => _service.getDiscountedPrice(t);
  String badgeText(Thuoc t) => _service.getBadgeText(t);
  String formatPrice(double p) => _service.formatMoney(p);
}
