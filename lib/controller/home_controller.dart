import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/models/thuoc.dart';
import 'package:nhathuoc_mobilee/service/productservice.dart';

class HomeController extends ChangeNotifier {
  final ProductService _service = ProductService();

  // ---------------------------------------------------------------------------
  // STATE VARIABLES
  // ---------------------------------------------------------------------------
  List<Thuoc> products = [];
  bool isLoading = true;
  String errorMessage = '';

  // ---------------------------------------------------------------------------
  // CONSTRUCTOR
  // ---------------------------------------------------------------------------
  HomeController() {
    fetchProducts();
  }

  // ---------------------------------------------------------------------------
  // PUBLIC METHODS
  // ---------------------------------------------------------------------------

  /// Tải danh sách sản phẩm mặc định
  Future<void> fetchProducts() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      products = await _service.getProducts();
    } catch (e) {
      errorMessage = "Không thể tải sản phẩm: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Tìm kiếm sản phẩm
  Future<void> onSearch(String keyword) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      if (keyword.trim().isEmpty) {
        // Nếu từ khóa rỗng, tải lại danh sách gốc
        products = await _service.getProducts();
      } else {
        // Gọi API tìm kiếm
        products = await _service.searchProductByNameOrUse(keyword);
      }
    } catch (e) {
      errorMessage = "Không tìm thấy kết quả phù hợp";
      products = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // UI HELPERS (Wrapper gọi Service)
  // ---------------------------------------------------------------------------
  bool checkPromo(Thuoc t) => _service.hasPromotion(t);
  double finalPrice(Thuoc t) => _service.getDiscountedPrice(t);
  String badgeText(Thuoc t) => _service.getBadgeText(t);
  String formatPrice(double p) => _service.formatMoney(p);
}