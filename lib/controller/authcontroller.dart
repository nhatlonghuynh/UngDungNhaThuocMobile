import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/service/authservice.dart';
import 'package:nhathuoc_mobilee/manager/usermanager.dart';

class AuthController extends ChangeNotifier {
  // Khởi tạo Service xử lý API
  final AuthService _service = AuthService();

  // ===========================================================================
  // 1. STATE MANAGEMENT (TRẠNG THÁI UI)
  // ===========================================================================

  bool isLoading = false; // Trạng thái đang tải (hiện xoay vòng)
  bool obscureText = true; // Trạng thái ẩn/hiện mật khẩu
  String errorMessage = ''; // Lưu lỗi nếu có (để hiển thị Text màu đỏ)

  // ===========================================================================
  // 2. GETTERS (TRUY XUẤT DỮ LIỆU)
  // ===========================================================================

  /// Kiểm tra xem người dùng đã đăng nhập chưa (lấy từ Singleton)
  bool get isLoggedIn => UserManager().isLoggedIn;

  /// Lấy thông tin người dùng hiện tại (nếu cần hiển thị Avatar/Tên)
  String? get currentUser => UserManager().hoTen;

  // ===========================================================================
  // 3. UI LOGIC (XỬ LÝ GIAO DIỆN)
  // ===========================================================================

  /// Hàm bật/tắt chế độ xem mật khẩu (Mắt đóng/mở)
  void togglePasswordVisibility() {
    obscureText = !obscureText;
    notifyListeners(); // Báo UI vẽ lại icon
  }

  /// Hàm làm mới UI (thường dùng khi quay lại từ màn hình khác)
  void refresh() {
    notifyListeners();
  }

  // ===========================================================================
  // 4. LOGIN LOGIC (ĐĂNG NHẬP)
  // ===========================================================================

  Future<Map<String, dynamic>> handleLogin(String phone, String pass) async {
    // 1. Validate đầu vào
    if (phone.trim().isEmpty || pass.trim().isEmpty) {
      return {
        'success': false,
        'message': 'Vui lòng nhập số điện thoại và mật khẩu',
      };
    }

    // 2. Bắt đầu loading
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    // 3. Gọi Service
    final result = await _service.login(phone, pass);

    // 4. Kết thúc loading
    isLoading = false;
    notifyListeners();

    return result; // Trả về kết quả cho UI xử lý chuyển màn hình
  }

  // ===========================================================================
  // 5. REGISTER LOGIC (ĐĂNG KÝ)
  // ===========================================================================

  Future<Map<String, dynamic>> handleRegister({
    required String name,
    required String phone,
    required String pass,
    required String confirmPass,
    required String gender,
    required String address, // Nên nhận address từ UI thay vì hardcode
  }) async {
    // 1. Validate cơ bản
    if (name.isEmpty || phone.isEmpty || pass.isEmpty || address.isEmpty) {
      return {'success': false, 'message': 'Vui lòng điền đầy đủ thông tin'};
    }

    // 2. Validate mật khẩu
    if (pass != confirmPass) {
      return {'success': false, 'message': 'Mật khẩu xác nhận không khớp'};
    }

    // 3. Bắt đầu loading
    isLoading = true;
    notifyListeners();

    // 4. Gọi Service
    final result = await _service.register(
      name: name,
      phone: phone,
      address: address,
      password: pass,
      gender: gender,
    );

    // 5. Kết thúc loading
    isLoading = false;
    notifyListeners();

    return result;
  }

  // ===========================================================================
  // 6. LOGOUT LOGIC (ĐĂNG XUẤT)
  // ===========================================================================

  Future<void> logout() async {
    // Xóa session và token trong máy
    await UserManager().logout();

    // Cập nhật UI để chuyển về chế độ Khách
    notifyListeners();
  }
}
