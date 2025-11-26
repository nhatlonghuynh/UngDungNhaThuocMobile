import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/service/userservice.dart';

class PasswordRecoveryController extends ChangeNotifier {
  final UserService _service = UserService();
  bool isLoading = false;

  /// Bước 1: Yêu cầu Token qua username/email
  Future<Map<String, dynamic>> requestToken(String username) async {
    try {
      isLoading = true;
      notifyListeners();
      return await _service.forgotPassword(username);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Bước 2: Gửi token và mật khẩu mới
  Future<Map<String, dynamic>> submitReset({
    required String username,
    required String token,
    required String newPass,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      return await _service.resetPassword(
        username: username,
        token: token,
        newPassword: newPass,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
