import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/models/thuoc.dart';
import 'package:nhathuoc_mobilee/service/productservice.dart';

class HomeController extends ChangeNotifier {
  final ProductService _service;

  List<Thuoc> products = [];
  bool isLoading = true;
  String errorMessage = '';

  HomeController({required ProductService service}) : _service = service {
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners(); // Báo UI hiện loading

    try {
      debugPrint("🏠 [Home] Fetching products...");
      products = await _service.getProducts();
    } catch (e) {
      errorMessage = "Lỗi: $e";
      debugPrint("❌ [Home] Fetch Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> onSearch(String keyword) async {
    isLoading = true;
    notifyListeners();

    try {
      if (keyword.trim().isEmpty) {
        debugPrint("🏠 [Home] Reset list (empty search)");
        products = await _service.getProducts();
      } else {
        debugPrint("🏠 [Home] Searching: $keyword");
        products = await _service.searchProductByNameOrUse(keyword);
      }
    } catch (e) {
      errorMessage = "Không tìm thấy sản phẩm";
      products = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Wrappers
  bool checkPromo(Thuoc t) => ProductService.hasPromotion(t);
  double finalPrice(Thuoc t) => ProductService.getDiscountedPrice(t);
  String badgeText(Thuoc t) => ProductService.getBadgeText(t);
  String formatPrice(double p) => ProductService.formatMoney(p);
}
