import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nhathuoc_mobilee/UI/common/constants/api_constants.dart';
import 'package:nhathuoc_mobilee/manager/usermanager.dart';

class ProfileRepository {
  // --- Helper: Lấy Header (Xử lý có hoặc không cần Token) ---
  Map<String, String> _getHeaders({bool requireAuth = true}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth) {
      final token = UserManager().accessToken;
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  /// =========================================================
  /// Hàm 1: updateProfileRequest
  /// Tác dụng: Cập nhật thông tin cá nhân (Họ tên, Email...)
  /// Endpoint: /api/account/update-profile
  /// =========================================================
  Future<http.Response> updateProfileRequest(Map<String, dynamic> data) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/account/update-profile');

    return await http.post(
      url,
      headers: _getHeaders(requireAuth: true),
      body: jsonEncode(data),
    );
  }

  /// =========================================================
  /// Hàm 2: changePasswordRequest
  /// Tác dụng: Đổi mật khẩu (cần mật khẩu cũ)
  /// Endpoint: /api/account/change-password
  /// =========================================================
  Future<http.Response> changePasswordRequest(Map<String, dynamic> data) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/account/change-password');

    return await http.post(
      url,
      headers: _getHeaders(requireAuth: true),
      body: jsonEncode(data),
    );
  }

  /// =========================================================
  /// Hàm 3: forgotPasswordRequest
  /// Tác dụng: Gửi yêu cầu quên mật khẩu (thường gửi OTP về email/sđt)
  /// Endpoint: /api/account/forgot-password
  /// =========================================================
  Future<http.Response> forgotPasswordRequest(String username) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/account/forgot-password');

    return await http.post(
      url,
      headers: _getHeaders(
        requireAuth: false,
      ), // Không cần token vì chưa đăng nhập
      body: jsonEncode({'Username': username}),
    );
  }

  /// =========================================================
  /// Hàm 4: resetPasswordRequest
  /// Tác dụng: Đặt lại mật khẩu mới (sau khi có OTP xác thực)
  /// Endpoint: /api/account/reset-password
  /// =========================================================
  Future<http.Response> resetPasswordRequest(Map<String, dynamic> data) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/account/reset-password');

    return await http.post(
      url,
      headers: _getHeaders(requireAuth: false),
      body: jsonEncode(data),
    );
  }

  // =========================================================
  // Hàm 5: getAddressesRequest
  // Tác dụng: Lấy danh sách địa chỉ của người dùng
  // Endpoint: /api/UserAddress/{userId}
  // =========================================================
  Future<http.Response> getAddressesRequest(String userId) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}/$userId',
    ); // Cần định nghĩa userAddressBaseUrl mới

    return await http.get(
      url,
      headers: _getHeaders(requireAuth: true), // Cần Token
    );
  }

  // =========================================================
  // Hàm 6: addAddressRequest
  // Tác dụng: Thêm địa chỉ mới
  // Endpoint: /api/UserAddress/{userId} (POST)
  // =========================================================
  Future<http.Response> addAddressRequest(
    String userId,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/$userId');

    return await http.post(
      url,
      headers: _getHeaders(requireAuth: true),
      body: jsonEncode(data),
    );
  }

  // =========================================================
  // Hàm 7: updateAddressRequest
  // Tác dụng: Cập nhật địa chỉ hiện có
  // Endpoint: /api/UserAddress/{addressID} (PUT)
  // =========================================================
  Future<http.Response> updateAddressRequest(
    int addressID,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/$addressID');

    return await http.put(
      url,
      headers: _getHeaders(requireAuth: true),
      body: jsonEncode(data),
    );
  }

  // =========================================================
  // Hàm 8: deleteAddressRequest
  // Tác dụng: Xóa địa chỉ
  // Endpoint: /api/UserAddress/{addressID} (DELETE)
  // =========================================================
  Future<http.Response> deleteAddressRequest(int addressID) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/$addressID');

    return await http.delete(url, headers: _getHeaders(requireAuth: true));
  }
}
