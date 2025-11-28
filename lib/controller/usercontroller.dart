import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/service/userservice.dart'; // Import Service

class ProfileController extends ChangeNotifier {
  final UserService _service = UserService();
  bool isLoading = false;

  /// Cập nhật thông tin User
  Future<Map<String, dynamic>> updateInfo({
    required String name,
    required String phone,
    required String gender,
    required String birthday,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      debugPrint("👤 [ProfileController] Update Profile: $name - $phone");

      // Gọi Service
      final result = await _service.updateProfile(
        name: name,
        phoneNumber: phone,
        gender: gender,
        birthday: birthday,
      );
      return result;
    } catch (e) {
      debugPrint("❌ [ProfileController] Lỗi Update: $e");
      return {'success': false, 'message': 'Lỗi ngoại lệ: $e'};
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Đổi mật khẩu
  Future<Map<String, dynamic>> changePass(
    String oldPass,
    String newPass,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      debugPrint("🔐 [ProfileController] Change Password...");

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
