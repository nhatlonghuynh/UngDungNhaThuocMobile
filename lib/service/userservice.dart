import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:nhathuoc_mobilee/api/userapi.dart';
import 'package:nhathuoc_mobilee/manager/usermanager.dart';

class UserService {
  final ProfileRepository _repo = ProfileRepository();

  // =======================================================================
  // 1. CẬP NHẬT THÔNG TIN CÁ NHÂN
  // =======================================================================
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required DateTime? dob, // Chỉ dùng DateTime
    required String email,
    required String phoneNumber,
    required String gender,
    required String address, 
  }) async {
    try {
      debugPrint("👤 [UserService] Update Profile: $name - $phoneNumber");
      String? dobString = dob?.toIso8601String();
      final body = {
        'Name_Customer': name,
        'PhoneNumber': phoneNumber,
        'Gender': gender,
        'Email': email, 
        'Address': address,
        'DateOfBirth': dobString,
      };

      final response = await _repo.updateProfileRequest(body);

      if (response.statusCode == 200) {
        final userMgr = UserManager();
        userMgr.hoTen = name;
        userMgr.soDienThoai = phoneNumber;
        userMgr.gioiTinh = gender;
        userMgr.diaChi = address; 
        if (dob != null) {
          userMgr.ngaySinh = dobString;
        }

        return {'success': true, 'message': 'Cập nhật thành công'};
      } else {
        return _handleError(response);
      }
    } catch (e) {
      debugPrint("❌ [UserService] Update Error: $e");
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // =======================================================================
  // 2. ĐỔI MẬT KHẨU
  // =======================================================================
  Future<Map<String, dynamic>> changePassword(
    String oldPass,
    String newPass,
  ) async {
    try {
      debugPrint("🔐 [UserService] Change Password...");
      final response = await _repo.changePasswordRequest({
        'OldPassword': oldPass,
        'NewPassword': newPass,
        'ConfirmPassword': newPass,
      });

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Đổi mật khẩu thành công'};
      } else {
        return _handleError(response);
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // =======================================================================
  // 3. QUÊN MẬT KHẨU & RESET
  // =======================================================================
  Future<Map<String, dynamic>> forgotPassword(String username) async {
    try {
      debugPrint("🔑 [UserService] Forgot Password: $username");
      final response = await _repo.forgotPasswordRequest(username);

      if (response.body.isEmpty) return _handleError(response);

      final data = jsonDecode(response.body);

      debugPrint("📩 [API Response]: $data");

      if (response.statusCode == 200) {
        String? token = data['resetToken'];

        if (token == null && data['data'] != null) {
          token = data['data']['resetToken'];
        }
        return {
          'success': true,
          'message': data['message'] ?? "Thành công",
          'resetToken': token ?? "",
        };
      } else {
        return _handleError(response);
      }
    } catch (e) {
      debugPrint("❌ Error: $e");
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String username,
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _repo.resetPasswordRequest({
        'Username': username,
        'Token': token,
        'NewPassword': newPassword,
        'ConfirmPassword': newPassword,
      });

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Đặt lại mật khẩu thành công'};
      } else {
        return _handleError(response);
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // --- Helper xử lý lỗi ---
  Map<String, dynamic> _handleError(http.Response response) {
    try {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      String msg = data['message'] ?? "Có lỗi xảy ra";

      if (data['ModelState'] != null) {
        var errors = data['ModelState'] as Map<String, dynamic>;
        if (errors.isNotEmpty) {
          var firstKey = errors.keys.first;
          msg = errors[firstKey][0];
        }
      }
      return {'success': false, 'message': msg};
    } catch (_) {
      return {
        'success': false,
        'message':
            'Lỗi server (${response.statusCode}): ${response.reasonPhrase}',
      };
    }
  }
}
