import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nhathuoc_mobilee/models/DanhMuc.dart';
import 'package:nhathuoc_mobilee/models/thuoc.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.2.9:8476/api';

  // ==========================================================
  // 1. Lấy cây danh mục
  // ----------------------------------------------------------
  // Gọi API lấy danh sách cây danh mục (Category Tree)
  // Trả về List<LoaiDanhMuc>
  // ==========================================================
  Future<List<LoaiDanhMuc>> fetchCategoryTree() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories/tree'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => LoaiDanhMuc.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      print("Lỗi tải danh mục: $e");
      return [];
    }
  }

  // ==========================================================
  // 2. Lấy thuốc theo bộ lọc
  // ----------------------------------------------------------
  // Gọi API filter backend đã xây dựng
  // Tham số lọc gồm typeId và catId (tùy chọn)
  // Trả về List<Thuoc>
  // ==========================================================
  Future<List<Thuoc>> fetchFilteredProducts({int? typeId, int? catId}) async {
    try {
      String url = '$baseUrl/thuoc/filter?';

      if (typeId != null) url += 'typeId=$typeId&';
      if (catId != null) url += 'catId=$catId&';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Thuoc.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      print("Lỗi tải thuốc: $e");
      return [];
    }
  }
}
