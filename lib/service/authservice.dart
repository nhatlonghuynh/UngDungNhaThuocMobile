import 'dart:convert';
import 'package:nhathuoc_mobilee/api/authapi.dart'; // Đổi lại đúng đường dẫn file Repository của bạn
import 'package:nhathuoc_mobilee/manager/usermanager.dart';

class AuthService {
  final AuthRepository _repository = AuthRepository();

  // --- XỬ LÝ ĐĂNG NHẬP ---
  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await _repository.loginRequest(phone, password);
      final body = jsonDecode(response.body); // Đây là toàn bộ cục JSON trả về

      // Check success từ Backend (vì Backend trả về 200 kèm success: false nếu lỗi logic)
      if (response.statusCode == 200 && body['success'] == true) {
        // --- QUAN TRỌNG: Lấy dữ liệu từ trong cục 'data' ---
        final userData = body['data'];

        // Mapping dữ liệu: Key bên trái (Lưu Local) = Key bên phải (Từ API Backend)
        Map<String, dynamic> userSaveData = {
          // 1. Token (C# trả về key 'token')
          'access_token': userData['token'],

          // 2. User ID (C# trả về key 'maKH')
          'user_id': userData['maKH'],

          // 3. Các thông tin khác
          'HoTen':
              userData['hoTen'] ??
          'Khách hàng', // C# trả về 'hoTen' (chữ thường đầu)
          'SoDienThoai': userData['soDienThoai'] ?? phone,
          'GioiTinh': userData['gender'] ?? 'Nam', // C# trả về 'gender'
          'DiaChi': userData['DiaChi'] ?? '',
          'DiemTichLuy': userData['DiemTichLuy'] ?? 0,
          'tongDiemTichLuy': userData['tongDiemTichLuy'] ?? 0,
          'capDo': userData['capDo'] ?? 'Mới',
        };

        // Lưu vào Singleton
        await UserManager().saveUser(userSaveData);
        return {'success': true};
      } else {
        // Lấy message lỗi từ body
        return {
          'success': false,
          'message': body['message'] ?? 'Đăng nhập thất bại',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // --- XỬ LÝ ĐĂNG KÝ ---
  Future<Map<String, dynamic>> register({
    required String phone,
    required String password,
    required String name,
    required String address,
    required String gender,
  }) async {
    try {
      final cleanedPhone = phone.trim().replaceAll(' ', '');

      // Key gửi lên Backend phải khớp với RegisterDTO trong C#
      final Map<String, dynamic> requestBody = {
        "Username": cleanedPhone,
        "Password": password,
        "ConfirmPassword": password,
        "Name_Customer": name,
        "PhoneNumber": cleanedPhone,
        "Address": address,
        "Gender": gender,
        "RoleType": "KhachHang",
        "Email":
            "$cleanedPhone@nhathuoc.com", // Fake email nếu backend bắt buộc
      };

      final response = await _repository.registerRequest(requestBody);
      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return {
          'success': true,
          'message':
              body['message'] ?? 'Đăng ký thành công! Vui lòng đăng nhập.',
        };
      } else {
        // Backend trả về message lỗi trực tiếp trong field 'message'
        return {
          'success': false,
          'message': body['message'] ?? 'Đăng ký thất bại',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
}
