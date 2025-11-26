import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/api/categoryapi.dart';
import 'package:nhathuoc_mobilee/models/DanhMuc.dart';

class CategoryController extends ChangeNotifier {
  final ApiService _service = ApiService();

  // ---------------------------------------------------------------------------
  // STATE VARIABLES
  // ---------------------------------------------------------------------------
  List<LoaiDanhMuc> tree = []; // Danh sách danh mục dạng cây
  bool isLoading = false;

  // ---------------------------------------------------------------------------
  // PUBLIC METHODS
  // ---------------------------------------------------------------------------

  /// Tải cây danh mục
  Future<void> loadCategories() async {
    // Nếu đã có dữ liệu thì không load lại (Cache đơn giản)
    if (tree.isNotEmpty) return;

    try {
      isLoading = true;
      notifyListeners();

      tree = await _service.fetchCategoryTree();
    } catch (e) {
      print("Lỗi tải danh mục: $e");
      tree = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
