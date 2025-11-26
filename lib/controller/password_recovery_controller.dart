import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/service/userservice.dart';

class PasswordRecoveryController extends ChangeNotifier {
  final UserService _service = UserService();
  bool isLoading = false;

  // Bước 1: Yêu cầu Token
  Future<Map<String, dynamic>> requestToken(String username) async {
    isLoading = true;
    notifyListeners();

    final result = await _service.forgotPassword(username);

    isLoading = false;
    notifyListeners();
    return result;
  }

  // Bước 2: Đổi mật khẩu mới
  Future<Map<String, dynamic>> submitReset({
    required String username,
    required String token,
    required String newPass,
  }) async {
    isLoading = true;
    notifyListeners();

    final result = await _service.resetPassword(
      username: username,
      token: token,
      newPassword: newPass,
    );

    isLoading = false;
    notifyListeners();
    return result;
  }
}
