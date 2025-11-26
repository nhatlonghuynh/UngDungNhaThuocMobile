import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/service/userservice.dart';

class ProfileController extends ChangeNotifier {
  final UserService _service = UserService();
  bool isLoading = false;

  // Cập nhật thông tin
  Future<Map<String, dynamic>> updateInfo({
    required String name,
    required String phone,
    required String gender,
    required String birthday,
  }) async {
    isLoading = true;
    notifyListeners();

    final result = await _service.updateProfile(
      name: name,
      phoneNumber: phone,
      gender: gender,
      birthday: birthday,
    );

    isLoading = false;
    notifyListeners();
    return result;
  }

  // Đổi mật khẩu
  Future<Map<String, dynamic>> changePass(
    String oldPass,
    String newPass,
  ) async {
    isLoading = true;
    notifyListeners();

    final result = await _service.changePassword(oldPass, newPass);

    isLoading = false;
    notifyListeners();
    return result;
  }
}
