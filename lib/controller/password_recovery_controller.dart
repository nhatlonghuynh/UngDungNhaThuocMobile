import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/service/userservice.dart';

class PasswordRecoveryController extends ChangeNotifier {
  final UserService _service = UserService();
  bool isLoading = false;

  // Bước 1: Yêu cầu Token
  Future<Map<String, dynamic>> requestToken(String username) async {
    try {
      isLoading = true;
      notifyListeners();

      debugPrint("🔑 [Controller] Request Token: $username");
      final result = await _service.forgotPassword(username);

      if (result['success'] == true) {
        debugPrint("✅ [Controller] Token received: ${result['resetToken']}");
      }
      return result;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Bước 2: Reset mật khẩu
  Future<Map<String, dynamic>> submitReset({
    required String username,
    required String token,
    required String newPass,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      debugPrint("🔄 [Controller] Resetting Password...");
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
