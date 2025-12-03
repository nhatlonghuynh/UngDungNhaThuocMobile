import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/api/categoryapi.dart';
import 'package:nhathuoc_mobilee/models/thuoc.dart';

class ProductFilterController extends ChangeNotifier {
  final DanhMucRepository _service;

  ProductFilterController({required DanhMucRepository service})
    : _service = service;

  // State
  List<Thuoc> products = [];
  bool isLoading = true;
  String message = '';

  /// Tải sản phẩm theo loại hoặc danh mục
  Future<void> loadProducts({int? typeId, int? catId}) async {
    isLoading = true;
    products = [];
    message = '';
    notifyListeners();

    try {
      products = await _service.fetchFilteredProducts(
        typeId: typeId,
        catId: catId,
      );
      if (products.isEmpty) {
        message = "Không tìm thấy sản phẩm nào.";
      }
    } catch (e) {
      message = "Lỗi kết nối: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
