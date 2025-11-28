import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/api/categoryapi.dart'; // Đổi lại đúng path Repository
import 'package:nhathuoc_mobilee/models/DanhMuc.dart';

class CategoryController extends ChangeNotifier {
  final DanhMucRepository _service = DanhMucRepository();

  List<LoaiDanhMuc> tree = [];
  bool isLoading = false;

  /// Tải cây danh mục
  Future<void> loadCategories() async {
    // Cache đơn giản: Có rồi thì không load lại
    if (tree.isNotEmpty) return;

    try {
      isLoading = true;
      notifyListeners();

      debugPrint("📂 [Controller] Loading Categories...");
      tree = await _service.fetchCategoryTree();
    } catch (e) {
      debugPrint("❌ [Controller] Load Error: $e");
      tree = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Hàm force refresh nếu cần (ví dụ vuốt xuống để làm mới)
  Future<void> refreshCategories() async {
    tree.clear();
    await loadCategories();
  }
}
