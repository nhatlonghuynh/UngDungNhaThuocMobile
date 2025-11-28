import 'dart:convert';
import 'package:flutter/foundation.dart'; // Để dùng debugPrint
import 'package:http/http.dart' as http;
import 'package:nhathuoc_mobilee/UI/common/constants/api_constants.dart';
import 'package:nhathuoc_mobilee/models/thuoc.dart';

class CartRepository {
  Future<List<Thuoc>> getProductsByIds(List<int> ids) async {
    if (ids.isEmpty) return [];

    // [DEBUG] Log Request
    final url = Uri.parse('${ApiConstants.baseUrl}/thuoc/get_cart');
    final body = jsonEncode({"ids": ids});

    debugPrint('🛒 [CartRepo] POST: $url');
    debugPrint('🛒 [CartRepo] Body: $body');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      // [DEBUG] Log Response
      debugPrint('🛒 [CartRepo] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        List<dynamic> rawList = jsonDecode(response.body);
        debugPrint(
          '🛒 [CartRepo] Đã lấy được ${rawList.length} sản phẩm từ Server',
        );
        return rawList.map((json) => Thuoc.fromJson(json)).toList();
      } else {
        debugPrint('❌ [CartRepo] Lỗi Server: ${response.body}');
        throw Exception("Lỗi Server: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint('❌ [CartRepo] Lỗi kết nối: $e');
      rethrow;
    }
  }
}
