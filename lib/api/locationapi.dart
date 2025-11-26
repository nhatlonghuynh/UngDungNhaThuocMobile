import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nhathuoc_mobilee/models/diachi.dart';

class LocationService {
  final String baseUrl = "https://provinces.open-api.vn/api/v1/?depth=3";

  // ==========================================================
  // 1. Lấy danh sách tỉnh / thành phố (kèm quận, phường)
  // ----------------------------------------------------------
  // Gọi API từ provinces.open-api.vn
  // Trả về List<Province>
  // ==========================================================
  Future<List<Province>> getProvinces() async {
    final res = await http.get(Uri.parse(baseUrl));

    if (res.statusCode != 200) {
      throw Exception("Failed to load provinces");
    }

    final list = json.decode(res.body) as List;
    return list.map((e) => Province.fromJson(e)).toList();
  }
}
