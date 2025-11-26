import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nhathuoc_mobilee/api/userapi.dart';
import 'package:nhathuoc_mobilee/manager/usermanager.dart';
import 'package:nhathuoc_mobilee/models/useraddress.dart';

class UserService {
  // Repository cho phần Profile/Account
  final ProfileRepository _profileRepo = ProfileRepository();

  // Base URL cho phần Address (Giữ nguyên từ code cũ của bạn)
  // Lưu ý: Hãy đảm bảo IP này đúng với server khi chạy máy thật/máy ảo
  final String _addressBaseUrl = "http://192.168.2.9:8476/api/UserAddress";

  // =======================================================================
  // PHẦN 1: QUẢN LÝ TÀI KHOẢN (PROFILE, PASSWORD)
  // =======================================================================

  // --- CẬP NHẬT THÔNG TIN CÁ NHÂN ---
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String phoneNumber,
    required String gender,
    required String birthday,
  }) async {
    try {
      final response = await _profileRepo.updateProfileRequest({
        'Name_Customer': name,
        'PhoneNumber': phoneNumber,
        'Gender': gender,
        'Email': "", // Tùy chọn, để trống nếu server không bắt buộc
        'Birthday': birthday,
      });

      if (response.statusCode == 200) {
        // Cập nhật thành công -> Lưu ngay vào bộ nhớ máy (Singleton)
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
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // --- ĐỔI MẬT KHẨU ---
  Future<Map<String, dynamic>> changePassword(
    String oldPass,
    String newPass,
  ) async {
    try {
      final response = await _profileRepo.changePasswordRequest({
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

  // --- QUÊN MẬT KHẨU (Lấy Token) ---
  Future<Map<String, dynamic>> forgotPassword(String username) async {
    try {
      final response = await _profileRepo.forgotPasswordRequest(username);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'resetToken': data['resetToken'], // Token để dùng cho bước reset
        };
      } else {
        return _handleError(response);
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // --- ĐẶT LẠI MẬT KHẨU (Dùng Token) ---
  Future<Map<String, dynamic>> resetPassword({
    required String username,
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _profileRepo.resetPasswordRequest({
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

  // Helper xử lý lỗi chung cho phần Profile
  Map<String, dynamic> _handleError(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      String msg = data['message'] ?? "Có lỗi xảy ra";

      // Xử lý lỗi ModelState của ASP.NET (Validation error)
      if (data['ModelState'] != null) {
        msg = data['ModelState'].values.first[0];
      }
      return {'success': false, 'message': msg};
    } catch (_) {
      return {
        'success': false,
        'message': 'Lỗi server: ${response.statusCode}',
      };
    }
  }

  // =======================================================================
  // PHẦN 2: QUẢN LÝ ĐỊA CHỈ NHẬN HÀNG (ADDRESS)
  // =======================================================================

  // Lấy danh sách địa chỉ
  Future<List<UserAddress>> getAddresses(String userId) async {
    try {
      final response = await http.get(Uri.parse("$_addressBaseUrl/$userId"));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((e) => UserAddress.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load addresses: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Lỗi kết nối khi lấy địa chỉ: $e");
    }
  }

  // Thêm địa chỉ mới
  Future<void> addAddress(String userId, UserAddress addr) async {
    try {
      final response = await http.post(
        Uri.parse("$_addressBaseUrl/$userId"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(addr.toJson()),
      );
      if (response.statusCode != 200) {
        throw Exception("Failed to add address: ${response.body}");
      }
    } catch (e) {
      throw Exception("Lỗi kết nối khi thêm địa chỉ: $e");
    }
  }

  // Cập nhật địa chỉ
  Future<void> updateAddress(UserAddress addr) async {
    try {
      final response = await http.put(
        Uri.parse("$_addressBaseUrl/${addr.addressID}"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(addr.toJson()),
      );
      if (response.statusCode != 200) {
        throw Exception("Failed to update address: ${response.body}");
      }
    } catch (e) {
      throw Exception("Lỗi kết nối khi sửa địa chỉ: $e");
    }
  }

  // Xóa địa chỉ
  Future<void> deleteAddress(int addressID) async {
    try {
      final response = await http.delete(
        Uri.parse("$_addressBaseUrl/$addressID"),
      );
      if (response.statusCode != 200) {
        throw Exception("Failed to delete address: ${response.body}");
      }
    } catch (e) {
      throw Exception("Lỗi kết nối khi xóa địa chỉ: $e");
    }
  }
}
