import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nhathuoc_mobilee/manager/usermanager.dart';
import 'package:nhathuoc_mobilee/common/constants/api_constants.dart';

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
  /// Tác dụng: Gửi dữ liệu đơn hàng lên Server để tạo đơn tạm (chờ thanh toán).
  /// Endpoint: /api/order/tao-don-tam
  /// =========================================================
  Future<http.Response> createOrderApi(Map<String, dynamic> data) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/order/tao-don-tam');

    return await http.post(url, headers: _getHeaders(), body: jsonEncode(data));
  }

  /// =========================================================
  /// Hàm 2: confirmPaymentApi
  /// Tác dụng: Gửi mã đơn hàng và mã giao dịch PayOS lên để xác nhận đã thanh toán xong.
  /// Endpoint: /api/order/webhook
  /// =========================================================
  Future<http.Response> confirmPaymentApi(int maHD, int payOSCode) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/order/webhook');

    return await http.post(
      url,
      headers: _getHeaders(),
      body: jsonEncode({"MaHD": maHD, "PayOSOrderCode": payOSCode}),
    );
  }
}
