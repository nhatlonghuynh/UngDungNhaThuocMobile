import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nhathuoc_mobilee/common/constants/api_constants.dart';

class AuthRepository {

  // 1. Gọi API Login
  Future<http.Response> loginRequest(String phone, String password) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/account/login');

    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"Username": phone, "Password": password}),
    );
  }

  // 2. Gọi API Register
  Future<http.Response> registerRequest(Map<String, dynamic> data) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/account/register');

    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
  }
}
