import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:nhathuoc_mobilee/api/userapi.dart'; // Đảm bảo import đúng ProfileRepository
import 'package:nhathuoc_mobilee/manager/usermanager.dart';

class UserService {
  final ProfileRepository _repo = ProfileRepository();

  // =======================================================================
  // 1. CẬP NHẬT THÔNG TIN CÁ NHÂN
  // =======================================================================
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String phoneNumber,
    required String gender,
    required String birthday,
  }) async {
    try {
      debugPrint("👤 [UserService] Update Profile: $name - $phoneNumber");

      final response = await _repo.updateProfileRequest({
        'Name_Customer': name,
        'PhoneNumber': phoneNumber,
        'Gender': gender,
        'Email': "", // Để trống nếu server không yêu cầu
        'Birthday': birthday,
      });

      if (response.statusCode == 200) {
        // Update thành công -> Lưu ngay vào Singleton UserManager
        final userMgr = UserManager();
        userMgr.hoTen = name;
        userMgr.soDienThoai = phoneNumber;
        userMgr.gioiTinh = gender;
        userMgr.ngaySinh = birthday;

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
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'resetToken': data['resetToken'],
        };
      } else {
        return _handleError(response);
      }
    } catch (e) {
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

  // --- Helper xử lý lỗi (Dùng chung trong class này) ---
  Map<String, dynamic> _handleError(http.Response response) {
    try {
      // Decode UTF8 để hiển thị tiếng Việt có dấu chuẩn
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      String msg = data['message'] ?? "Có lỗi xảy ra";

      // Xử lý lỗi ModelState (ASP.NET)
      if (data['ModelState'] != null) {
        msg = data['ModelState'].values.first[0];
      }
      return {'success': false, 'message': msg};
    } catch (_) {
      return {
        'success': false,
        'message': 'Lỗi server (${response.statusCode})',
      };
    }
  }
}
