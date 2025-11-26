import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/manager/usermanager.dart';
import 'package:nhathuoc_mobilee/service/authservice.dart';

class AuthController extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // 1. SERVICES & DEPENDENCIES
  // ---------------------------------------------------------------------------
  final AuthService _service = AuthService();

  // ---------------------------------------------------------------------------
  // 2. STATE VARIABLES (Biến trạng thái)
  // ---------------------------------------------------------------------------
  bool isLoading = false; // Hiển thị vòng xoay loading
  bool obscureText = true; // Ẩn/Hiện mật khẩu
  String errorMessage = ''; // Lưu thông báo lỗi

  // ---------------------------------------------------------------------------
  // 3. GETTERS (Dữ liệu cho UI)
  // ---------------------------------------------------------------------------
  bool get isLoggedIn => UserManager().isLoggedIn;
  String? get currentUserName => UserManager().hoTen;

  // ---------------------------------------------------------------------------
  // 4. UI LOGIC (Hành động trên giao diện)
  // ---------------------------------------------------------------------------

  // Chuyển đổi trạng thái ẩn/hiện mật khẩu
  void togglePasswordVisibility() {
    obscureText = !obscureText;
    notifyListeners();
  }

  // Làm mới UI (dùng khi quay lại từ màn hình khác)
  void refresh() {
    errorMessage = '';
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // 5. BUSINESS LOGIC (Xử lý nghiệp vụ)
  // ---------------------------------------------------------------------------

  /// Xử lý Đăng nhập
  Future<Map<String, dynamic>> handleLogin(String phone, String pass) async {
    // Validate
    if (phone.trim().isEmpty || pass.trim().isEmpty) {
      return {
        'success': false,
        'message': 'Vui lòng nhập số điện thoại và mật khẩu',
      };
    }

    try {
      isLoading = true;
      errorMessage = '';
      notifyListeners();

      // Gọi API
      final result = await _service.login(phone, pass);
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Lỗi đăng nhập: $e'};
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
    // Validate
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
      return {'success': false, 'message': 'Lỗi đăng ký: $e'};
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Xử lý Đăng xuất
  Future<void> logout() async {
    await UserManager().logout();
    notifyListeners(); // Cập nhật UI về trạng thái chưa đăng nhập
  }
}
