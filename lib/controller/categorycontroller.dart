import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/api/categoryapi.dart';
import 'package:nhathuoc_mobilee/models/DanhMuc.dart';

class CategoryController extends ChangeNotifier {
  final ApiService _service = ApiService();

  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------
  List<LoaiDanhMuc> tree = []; // Cây danh mục
  bool isLoading = false; // Hiển thị loading

  // ---------------------------------------------------------------------------
  // 1. Tải danh mục từ API
  // ---------------------------------------------------------------------------
  Future<void> loadCategories() async {
    if (tree.isNotEmpty) return; // Nếu đã tải rồi, không tải lại

    isLoading = true;
    notifyListeners();

    tree = await _service.fetchCategoryTree();

    isLoading = false;
    notifyListeners();
  }
}
