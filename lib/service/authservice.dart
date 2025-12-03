import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:nhathuoc_mobilee/api/authapi.dart'; // Đổi lại đúng path Repository
import 'package:nhathuoc_mobilee/manager/usermanager.dart';

class AuthService {
  final AuthRepository _repository = AuthRepository();

  // --- XỬ LÝ ĐĂNG NHẬP ---
  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await _repository.loginRequest(phone, password);

      // [DEBUG] Log Response Raw
      debugPrint('⬅️ [RESPONSE] Status: ${response.statusCode}');
      debugPrint('⬅️ [RESPONSE] Body: ${response.body}');

      if (response.statusCode != 200) {
        return {
          'success': false,
          'message': 'Lỗi Server: ${response.statusCode}',
        };
      }

      final body = jsonDecode(response.body);

      // Check success từ logic Backend
      if (body['success'] == true) {
        final userData = body['data'];

        // [DEBUG] Kiểm tra data trước khi map
        debugPrint('✅ [LOGIN DATA]: $userData');

        // Mapping dữ liệu
        Map<String, dynamic> userSaveData = {
          'access_token': userData['token'],
          'khachhang_id': userData['MaKH'],
          'user_id': userData['maTK'],
          'HoTen': userData['hoTen'] ?? 'Khách hàng',
          'SoDienThoai': userData['soDienThoai'] ?? phone,
          'GioiTinh': userData['gioiTinh'] ?? 'Nam',
          'DiaChi': userData['diaChi'] ?? '',
          'DiemTichLuy': userData['diemTichLuy'] ?? 0,
          'capDo': userData['capDo'] ?? 'Mới',
        };

        // Lưu vào Singleton
        await UserManager().saveUser(userSaveData);
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'Đăng nhập thất bại (Logic)',
        };
      }
    } catch (e, stackTrace) {
      // [DEBUG] In lỗi chi tiết
      debugPrint('❌ [LOGIN ERROR]: $e');
      debugPrint('Stacktrace: $stackTrace');
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // --- XỬ LÝ ĐĂNG KÝ ---
  Future<Map<String, dynamic>> register({
    required String phone,
    required String password,
    required String name,
    required String address,
    required String gender,
  }) async {
    try {
      final cleanedPhone = phone.trim().replaceAll(' ', '');

      final Map<String, dynamic> requestBody = {
        "Username": cleanedPhone,
        "Password": password,
        "ConfirmPassword": password,
        "Name_Customer": name,
        "PhoneNumber": cleanedPhone,
        "DateOfBirth": null,
        "City":'',
        "Address": address,
        "Gender": gender,
        "RoleType": "KhachHang",
        "Email": "$cleanedPhone@nhathuoc.com",
      };

      final response = await _repository.registerRequest(requestBody);

      // [DEBUG] Log Response
      debugPrint('⬅️ [RESPONSE REGISTER] Status: ${response.statusCode}');
      debugPrint('⬅️ [RESPONSE REGISTER] Body: ${response.body}');

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return {
          'success': true,
          'message': body['message'] ?? 'Đăng ký thành công!',
        };
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'Đăng ký thất bại',
        };
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [REGISTER ERROR]: $e');
      debugPrint('Stacktrace: $stackTrace');
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
}
