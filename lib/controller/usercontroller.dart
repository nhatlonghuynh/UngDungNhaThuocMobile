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
    required String birthday,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      return await _service.updateProfile(
        name: name,
        phoneNumber: phone,
        gender: gender,
        birthday: birthday,
      );
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
    try {
      isLoading = true;
      notifyListeners();

      return await _service.changePassword(oldPass, newPass);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
