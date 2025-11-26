import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/api/categoryapi.dart';
import 'package:nhathuoc_mobilee/models/thuoc.dart';

class ProductFilterController extends ChangeNotifier {
  final ApiService _service = ApiService();
  List<Thuoc> products = [];
  bool isLoading = true;
  String message = '';

  Future<void> loadProducts({int? typeId, int? catId}) async {
    isLoading = true;
    products = [];
    message = '';
    notifyListeners();

    try {
      products = await _service.fetchFilteredProducts(typeId: typeId, catId: catId);
      if (products.isEmpty) {
        message = "Không tìm thấy sản phẩm nào.";
      }
    } catch (e) {
      message = "Lỗi kết nối: $e";
    }

    isLoading = false;
    notifyListeners();
  }
}