import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/service/userservice.dart';

class ProfileController extends ChangeNotifier {
  final UserService _service = UserService();
  bool isLoading = false;

  /// Cập nhật thông tin User
  Future<Map<String, dynamic>> updateInfo({
    required String name,
    required String phone,
    required String gender,
    required DateTime? dob, // Chỉ dùng DateTime, bỏ String birthday
    required String email,
    required String address, // [QUAN TRỌNG] Thêm trường này
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      debugPrint("👤 [ProfileController] Update Profile: $name - $phone");

      // Gọi Service (Đảm bảo UserService cũng đã thêm tham số address)
      final result = await _service.updateProfile(
        name: name,
        dob: dob,
        phoneNumber: phone,
        gender: gender,
        email: email,
        address: address, // Truyền địa chỉ xuống Service
      );
      
      // Nếu thành công, có thể cần update lại UserManager singleton tại đây
      // để UI tự động hiển thị thông tin mới
      if (result['success'] == true) {
         // UserManager().hoTen = name;
         // UserManager().diaChi = address;
         // ...
      }

      return result;
    } catch (e) {
      debugPrint("❌ [ProfileController] Lỗi Update: $e");
      return {'success': false, 'message': 'Lỗi ngoại lệ: $e'};
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Đổi mật khẩu (Phần này OK, khớp với Backend ChangePasswordDTO)
  Future<Map<String, dynamic>> changePass(
    String oldPass,
    String newPass,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      debugPrint("🔐 [ProfileController] Change Password...");
      
      // Backend yêu cầu: OldPassword, NewPassword
      final result = await _service.changePassword(oldPass, newPass);
      return result;
    } catch (e) {
      debugPrint("❌ [ProfileController] Lỗi Change Pass: $e");
      return {'success': false, 'message': 'Lỗi ngoại lệ: $e'};
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}