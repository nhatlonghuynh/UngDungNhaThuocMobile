import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PayOSService {
  // ==========================================================
  // Base URLs từ .env
  // ==========================================================
  final String? orderUrl = dotenv.env['ORDER_URL'];
  final String? vietQrUrl = dotenv.env['VIETQR_URL'];

  // ==========================================================
  // 1. Tạo Payment Link PayOS
  // ----------------------------------------------------------
  // API: POST https://api-demo.payos.vn/order/create
  // Input: formValue (json)
  // Output: Response JSON
  // ==========================================================
  Future<Map<String, dynamic>> createPaymentLink(
    Map<String, dynamic> formValue,
  ) async {
    try {
      final url = Uri.parse('https://api-demo.payos.vn/order/create');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(formValue),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create payment link');
      }
    } catch (e) {
      return {'error': 1};
    }
  }

  // ==========================================================
  // 2. Lấy thông tin đơn PayOS
  // ----------------------------------------------------------
  // API: GET {ORDER_URL}/order/{orderId}
  // ==========================================================
  Future<Map<String, dynamic>> getOrder(String orderId) async {
    try {
      final url = Uri.parse('$orderUrl/order/$orderId');

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get Order');
      }
    } catch (e) {
      return {'error': 1};
    }
  }

  // ==========================================================
  // 3. Lấy danh sách ngân hàng VietQR
  // ----------------------------------------------------------
  // API: GET {VIETQR_URL}
  // ==========================================================
  Future<Map<String, dynamic>> getBankList() async {
    try {
      final url = Uri.parse(vietQrUrl!);

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get Bank List');
      }
    } catch (e) {
      return {'error': 1};
    }
  }

  // ==========================================================
  // 4. Hủy đơn PayOS
  // ----------------------------------------------------------
  // API: POST {ORDER_URL}/order/{orderId}/cancel
  // ==========================================================
  Future<Map<String, dynamic>> cancelOrder(String orderId) async {
    try {
      final url = Uri.parse('$orderUrl/order/$orderId/cancel');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to cancel Order');
      }
    } catch (e) {
      return {'error': 1};
    }
  }
}
