import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; // Để dùng debugPrint
import 'package:nhathuoc_mobilee/models/diachi.dart';

class LocationRepository {
  // ==========================================================
  // Lấy danh sách tỉnh/thành từ assets
  // ==========================================================
  Future<List<Province>> getProvinces() async {
    try {
      debugPrint(
        "📍 [LocationRepo] Đang đọc file assets/data/provinces.json...",
      );

      // Đọc file JSON
      final jsonString = await rootBundle.loadString(
        'assets/data/provinces.json',
      );

      // Parse JSON
      final list = json.decode(jsonString) as List;

      debugPrint("📍 [LocationRepo] Đã load được ${list.length} tỉnh/thành");

      // Chuyển sang danh sách Province
      return list.map((e) => Province.fromJson(e)).toList();
    } catch (e) {
      debugPrint("❌ [LocationRepo] Lỗi đọc file địa chính: $e");
      // Trả về list rỗng để không crash app
      return [];
    }
  }
}
