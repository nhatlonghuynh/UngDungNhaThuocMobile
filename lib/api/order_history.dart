import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:nhathuoc_mobilee/UI/common/constants/api_constants.dart';
import 'package:nhathuoc_mobilee/manager/usermanager.dart';

class OrderHistoryRepository {
  Future<Map<String, String>> _getHeaders() async {
    final token =
        UserManager().accessToken; // Đã sửa: dùng getter đồng bộ cho nhanh
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    };
  }

  // 1. Lấy danh sách
  Future<http.Response> getOrderHistory(String status) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/history/list?status=$status',
    );

    debugPrint('➡️ [HistoryRepo] GET List: $uri');

    final headers = await _getHeaders();
    return await http.get(uri, headers: headers);
  }

  // 2. Lấy chi tiết
  Future<http.Response> getOrderDetail(int orderId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/history/detail/$orderId');

    debugPrint('➡️ [HistoryRepo] GET Detail: $orderId');

    final headers = await _getHeaders();
    return await http.get(uri, headers: headers);
  }

  // 3. Hủy đơn
  Future<http.Response> cancelOrder(int orderId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/order/yeu-cau-huy');

    debugPrint('➡️ [HistoryRepo] POST Cancel: $orderId');

    final headers = await _getHeaders();
    final body = jsonEncode({"MaHD": orderId});

    return await http.post(uri, headers: headers, body: body);
  }
}
