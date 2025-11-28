import 'dart:convert';
import 'package:flutter/foundation.dart'; // DebugPrint
import 'package:http/http.dart' as http;
import 'package:nhathuoc_mobilee/UI/common/constants/api_constants.dart';
import 'package:nhathuoc_mobilee/models/thuoc.dart';

class ProductRepository {
  // 1. Lấy tất cả sản phẩm
  Future<List<Thuoc>> fetchAllProducts() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/thuoc/all');

    debugPrint('📦 [ProductRepo] GET All: $url');

    try {
      final response = await http.get(url);

      debugPrint('⬅️ [ProductRepo] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Decode UTF8 để tránh lỗi font tiếng Việt
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        debugPrint('📦 [ProductRepo] Loaded ${data.length} items');
        return data.map((e) => Thuoc.fromJson(e)).toList();
      } else {
        throw Exception("Lỗi tải dữ liệu: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ [ProductRepo] Error: $e");
      throw Exception("Lỗi kết nối: $e");
    }
  }

  // 2. Lấy chi tiết (Trả về Response thô để Service xử lý)
  Future<http.Response> getDetailRequest(int id) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/thuoc/detail/$id');
    debugPrint('📦 [ProductRepo] GET Detail ID: $id');
    return await http.get(url);
  }

  // 3. Tìm kiếm
  Future<List<Thuoc>> searchProducts(String keyword) async {
    // Encode từ khóa để tránh lỗi URL
    final encodedKeyword = Uri.encodeComponent(keyword);
    final url = Uri.parse(
      '${ApiConstants.baseUrl}/thuoc/filter?keyword=$encodedKeyword',
    );

    debugPrint('🔍 [ProductRepo] Search: $keyword');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        debugPrint('🔍 [ProductRepo] Found ${data.length} results');
        return data.map((e) => Thuoc.fromJson(e)).toList();
      } else {
        throw Exception("Lỗi tìm kiếm: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ [ProductRepo] Search Error: $e");
      throw Exception("Lỗi kết nối: $e");
    }
  }
}
