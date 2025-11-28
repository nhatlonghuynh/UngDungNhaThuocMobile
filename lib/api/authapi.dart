import 'dart:convert';
import 'package:flutter/foundation.dart'; // Để dùng debugPrint
import 'package:http/http.dart' as http;
import 'package:nhathuoc_mobilee/UI/common/constants/api_constants.dart';

class AuthRepository {
  // Helper headers
  Map<String, String> get _headers => {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  // 1. Gọi API Login
  Future<http.Response> loginRequest(String phone, String password) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/account/login');
    final body = jsonEncode({"Username": phone, "Password": password});

    // [DEBUG] Log Request
    debugPrint('➡️ [POST] URL: $url');
    debugPrint('➡️ [POST] Body: $body');

    return await http.post(url, headers: _headers, body: body);
  }

  // 2. Gọi API Register
  Future<http.Response> registerRequest(Map<String, dynamic> data) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/account/register');
    final body = jsonEncode(data);

    // [DEBUG] Log Request
    debugPrint('➡️ [POST] URL: $url');
    debugPrint('➡️ [POST] Body: $body');

    return await http.post(url, headers: _headers, body: body);
  }
}
