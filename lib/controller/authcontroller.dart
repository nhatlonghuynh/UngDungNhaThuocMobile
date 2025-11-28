import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/manager/usermanager.dart';
import 'package:nhathuoc_mobilee/service/authservice.dart'; // Đổi lại đúng path

class AuthController extends ChangeNotifier {
  final AuthService _service = AuthService();

  bool isLoading = false;
  bool obscureText = true;
  String errorMessage = '';

  // Getters
  bool get isLoggedIn => UserManager().isLoggedIn;
  String? get currentUserName => UserManager().hoTen;

  // UI Logic
  void togglePasswordVisibility() {
    obscureText = !obscureText;
    notifyListeners();
  }

  void refresh() {
    errorMessage = '';
    notifyListeners();
  }

  // --- BUSINESS LOGIC ---

  /// Xử lý Đăng nhập
  Future<Map<String, dynamic>> handleLogin(String phone, String pass) async {
    debugPrint("👉 [Controller] Bắt đầu Login: $phone");

    if (phone.trim().isEmpty || pass.trim().isEmpty) {
      return {'success': false, 'message': 'Vui lòng nhập đủ thông tin'};
    }

    try {
      isLoading = true;
      errorMessage = '';
      notifyListeners();

      final result = await _service.login(phone, pass);

      if (!result['success']) {
        errorMessage = result['message'];
      }
      return result;
    } catch (e) {
      debugPrint("❌ [Controller Exception]: $e");
      return {'success': false, 'message': 'Lỗi không xác định: $e'};
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Xử lý Đăng ký
  Future<Map<String, dynamic>> handleRegister({
    required String name,
    required String phone,
    required String pass,
    required String confirmPass,
    required String gender,
    required String address,
  }) async {
    debugPrint("👉 [Controller] Bắt đầu Register: $phone");

    if (name.isEmpty || phone.isEmpty || pass.isEmpty || address.isEmpty) {
      return {'success': false, 'message': 'Vui lòng điền đầy đủ thông tin'};
    }
    if (pass != confirmPass) {
      return {'success': false, 'message': 'Mật khẩu xác nhận không khớp'};
    }

    try {
      isLoading = true;
      notifyListeners();

      final result = await _service.register(
        name: name,
        phone: phone,
        address: address,
        password: pass,
        gender: gender,
      );
      return result;
    } catch (e) {
      debugPrint("❌ [Controller Exception]: $e");
      return {'success': false, 'message': 'Lỗi đăng ký: $e'};
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Xử lý Đăng xuất
  Future<void> logout() async {
    await UserManager().logout();
    notifyListeners();
    debugPrint("👉 [Controller] Đã đăng xuất");
  }
}
