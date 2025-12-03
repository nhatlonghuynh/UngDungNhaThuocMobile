import 'dart:convert';
import 'package:flutter/foundation.dart'; // Để dùng debugPrint
import 'package:http/http.dart' as http;
import 'package:nhathuoc_mobilee/UI/common/constants/api_constants.dart';
import 'package:nhathuoc_mobilee/models/DanhMuc.dart';
import 'package:nhathuoc_mobilee/models/thuoc.dart';

class DanhMucRepository {
  // ==========================================================
  // 1. Lấy cây danh mục
  // ==========================================================
  Future<List<LoaiDanhMuc>> fetchCategoryTree() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/categories/tree');

    // [DEBUG]
    debugPrint('📂 [CategoryRepo] GET Tree: $url');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        debugPrint('📂 [CategoryRepo] Loaded ${data.length} parent categories');
        return data.map((e) => LoaiDanhMuc.fromJson(e)).toList();
      } else {
        debugPrint(
          '❌ [CategoryRepo] Error ${response.statusCode}: ${response.body}',
        );
        return [];
      }
    } catch (e) {
      debugPrint("❌ [CategoryRepo] Exception: $e");
      return [];
    }
  }

  // ==========================================================
  // 2. Lấy thuốc theo bộ lọc (Xử lý Query Param chuẩn)
  // ==========================================================
  Future<List<Thuoc>> fetchFilteredProducts({int? typeId, int? catId}) async {
    try {
      // 1. Tạo Map chứa tham số (Chỉ thêm cái nào khác null)
      final Map<String, String> queryParams = {};
      if (typeId != null) queryParams['typeId'] = typeId.toString();
      if (catId != null) queryParams['catId'] = catId.toString();

      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/thuoc/filter',
      ).replace(queryParameters: queryParams);

      // [DEBUG]
      debugPrint('🔍 [FilterRepo] GET: $uri');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        debugPrint('🔍 [FilterRepo] Found ${data.length} products');
        return data.map((e) => Thuoc.fromJson(e)).toList();
      }

      debugPrint('❌ [FilterRepo] Error ${response.statusCode}');
      return [];
    } catch (e) {
      debugPrint("❌ [FilterRepo] Exception: $e");
      return [];
    }
  }
}
