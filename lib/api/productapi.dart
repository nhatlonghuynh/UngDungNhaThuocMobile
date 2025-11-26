import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nhathuoc_mobilee/models/thuoc.dart';

class ProductRepository {
  // ==========================================================
  // Base URL Backend
  // ----------------------------------------------------------
  // Lưu ý thay IP khi đổi máy chủ Backend
  // ==========================================================
  static const String _baseUrl = 'http://192.168.2.9:8476/api';

  // ==========================================================
  // 1. Lấy danh sách tất cả sản phẩm
  // ----------------------------------------------------------
  // API: GET /thuoc/all
  // Trả về List<Thuoc>
  // ==========================================================
  Future<List<Thuoc>> fetchAllProducts() async {
    final url = Uri.parse('$_baseUrl/thuoc/all');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((e) => Thuoc.fromJson(e)).toList();
      } else {
        throw Exception("Lỗi tải dữ liệu: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Lỗi kết nối: $e");
    }
  }

  // ==========================================================
  // 2. Lấy chi tiết 1 sản phẩm
  // ----------------------------------------------------------
  // API: GET /thuoc/detail/{id}
  // Trả về http.Response (Controller xử lý tiếp)
  // ==========================================================
  Future<http.Response> getDetailRequest(int id) async {
    final url = Uri.parse('$_baseUrl/thuoc/detail/$id');
    return await http.get(url);
  }

  // ==========================================================
  // 3. Tìm kiếm sản phẩm theo từ khóa
  // ----------------------------------------------------------
  // API: GET /thuoc/filter?keyword=...
  // Có encode UTF8 để hỗ trợ tiếng Việt
  // ==========================================================
  Future<List<Thuoc>> searchProducts(String keyword) async {
    final encodedKeyword = Uri.encodeComponent(keyword);
    final url = Uri.parse('$_baseUrl/thuoc/filter?keyword=$encodedKeyword');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((e) => Thuoc.fromJson(e)).toList();
      } else {
        throw Exception("Lỗi tìm kiếm: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Lỗi kết nối: $e");
    }
  }
}
