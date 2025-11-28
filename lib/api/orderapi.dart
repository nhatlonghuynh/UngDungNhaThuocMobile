import 'dart:convert';
import 'package:flutter/foundation.dart'; // Để dùng debugPrint
import 'package:http/http.dart' as http;
import 'package:nhathuoc_mobilee/UI/common/constants/api_constants.dart';
import 'package:nhathuoc_mobilee/manager/usermanager.dart';

class OrderRepository {
  // --- Helper: Lấy Header chung (kèm Token) ---
  Map<String, String> _getHeaders() {
    return {
      "Content-Type": "application/json",
      // Lấy token từ bộ nhớ đệm (UserManager) để xác thực
      "Authorization": "Bearer ${UserManager().accessToken}",
    };
  }

  /// =========================================================
  /// Hàm 1: createOrderApi
  /// Tác dụng: Gửi dữ liệu đơn hàng lên Server để tạo đơn tạm.
  /// Endpoint: /api/order/tao-don-tam
  /// =========================================================
  Future<http.Response> createOrderApi(Map<String, dynamic> data) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/order/tao-don-tam');

    final prettyJson = const JsonEncoder.withIndent('  ').convert(data);

    debugPrint('➡️ [OrderRepo] POST Create Order: $url');
    debugPrint('➡️ [OrderRepo] BODY gửi đi:\n$prettyJson');

    return await http.post(url, headers: _getHeaders(), body: jsonEncode(data));
  }

  /// =========================================================
  /// Hàm 2: confirmPaymentApi
  /// Tác dụng: Xác nhận thanh toán PayOS (Webhook)
  /// Endpoint: /api/order/webhook
  /// =========================================================
  Future<http.Response> confirmPaymentApi(int maHD, int payOSCode) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/order/webhook');
    final body = {"MaHD": maHD, "PayOSOrderCode": payOSCode};

    // [DEBUG] In ra log xác nhận
    debugPrint('➡️ [OrderRepo] POST Confirm Payment: $url');
    debugPrint('➡️ [OrderRepo] Body: $body');

    return await http.post(url, headers: _getHeaders(), body: jsonEncode(body));
  }
}
