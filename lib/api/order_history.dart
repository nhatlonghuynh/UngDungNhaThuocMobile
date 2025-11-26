import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nhathuoc_mobilee/manager/usermanager.dart';

class OrderHistoryRepository {
  // Base URL Backend
  static const String _baseUrl = 'http://192.168.2.9:8476/api';

  // ==========================================================
  // Helper: Lấy header kèm Token
  // ----------------------------------------------------------
  // Dùng cho tất cả request yêu cầu xác thực
  // ==========================================================
  Future<Map<String, String>> _getHeaders() async {
    final token = await UserManager().getToken();

    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    };
  }

  // ==========================================================
  // 1. Lấy danh sách lịch sử đơn hàng
  // ----------------------------------------------------------
  // Gọi API: /history/list?status={status}
  // Không cần userId vì backend tự đọc từ Token
  // ==========================================================
  Future<http.Response> getOrderHistory(String status) async {
    final uri = Uri.parse('$_baseUrl/history/list?status=$status');
    final headers = await _getHeaders();

    return await http.get(uri, headers: headers);
  }

  // ==========================================================
  // 2. Lấy chi tiết đơn hàng
  // ----------------------------------------------------------
  // Gọi API: /history/detail/{orderId}
  // Trả về detail đơn
  // ==========================================================
  Future<http.Response> getOrderDetail(int orderId) async {
    final uri = Uri.parse('$_baseUrl/history/detail/$orderId');
    final headers = await _getHeaders();

    return await http.get(uri, headers: headers);
  }

  // ==========================================================
  // 3. Yêu cầu hủy đơn hàng
  // ----------------------------------------------------------
  // Gọi API: POST /order/yeu-cau-huy
  // Body gửi theo HuyDonRequest -> {"MaHD": orderId}
  // ==========================================================
  Future<http.Response> cancelOrder(int orderId) async {
    final uri = Uri.parse('$_baseUrl/order/yeu-cau-huy');
    final headers = await _getHeaders();

    final body = jsonEncode({"MaHD": orderId});

    return await http.post(uri, headers: headers, body: body);
  }
}
