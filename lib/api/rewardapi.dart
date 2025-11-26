import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nhathuoc_mobilee/UI/common/constants/api_constants.dart';
import 'package:nhathuoc_mobilee/manager/usermanager.dart';

class RewardRepository {
  // --- Helper: Lấy Header chung (kèm Token) ---
  Map<String, String> _getHeaders() {
    final token = UserManager().accessToken;
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  /// =========================================================
  /// Hàm 1: fetchGiftsRequest
  /// Tác dụng: Lấy danh sách quà đổi thưởng hiện có.
  /// Endpoint: /api/reward/list
  /// =========================================================
  Future<http.Response> fetchGiftsRequest() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/reward/list');

    return await http.get(url, headers: _getHeaders());
  }

  /// =========================================================
  /// Hàm 2: redeemGiftRequest
  /// Tác dụng: Gửi yêu cầu đổi điểm lấy quà.
  /// Endpoint: /api/reward/redeem
  /// Body ví dụ: { "GiftId": 1, "Quantity": 1 }
  /// =========================================================
  Future<http.Response> redeemGiftRequest(Map<String, dynamic> body) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/reward/redeem');

    return await http.post(url, headers: _getHeaders(), body: jsonEncode(body));
  }
}
