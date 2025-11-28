import 'dart:convert';
import 'package:flutter/foundation.dart'; // Để dùng debugPrint
import 'package:http/http.dart' as http;
import 'package:nhathuoc_mobilee/UI/common/constants/api_constants.dart';
import 'package:nhathuoc_mobilee/manager/usermanager.dart';

class RewardRepository {
  // Helper lấy Header
  Map<String, String> _getHeaders() {
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${UserManager().accessToken}",
    };
  }

  // 1. Lấy danh sách quà
  Future<http.Response> fetchGiftsRequest() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/reward/list');

    debugPrint('🎁 [RewardRepo] GET List: $url');

    return await http.get(url, headers: _getHeaders());
  }

  // 2. Đổi quà
  Future<http.Response> redeemGiftRequest(Map<String, dynamic> body) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/reward/redeem');

    debugPrint('🎁 [RewardRepo] POST Redeem: $url');
    debugPrint('🎁 Body: ${jsonEncode(body)}');

    return await http.post(url, headers: _getHeaders(), body: jsonEncode(body));
  }
}
