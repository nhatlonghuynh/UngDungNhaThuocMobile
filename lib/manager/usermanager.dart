import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserManager {
  // ---------------------------------------------------------------------------
  // 1. SINGLETON
  // ---------------------------------------------------------------------------
  static final UserManager _instance = UserManager._internal();
  factory UserManager() => _instance;
  UserManager._internal();

  // Biến lưu user trên RAM
  Map<String, dynamic>? _currentUser;

  // ---------------------------------------------------------------------------
  // 2. GETTERS / SETTERS
  // ---------------------------------------------------------------------------

  bool get isLoggedIn => _currentUser != null;
  String? get accessToken => _currentUser?['access_token'];
  String get userId => _currentUser?['user_id'] ?? '';

  // Thông tin cá nhân
  String get hoTen => _currentUser?['HoTen'] ?? 'Khách hàng';
  set hoTen(String value) => _setUserField('HoTen', value);

  String get soDienThoai => _currentUser?['SoDienThoai'] ?? '';
  set soDienThoai(String value) => _setUserField('SoDienThoai', value);

  String? get diaChi => _currentUser?['DiaChi'];
  set diaChi(String value) => _setUserField('DiaChi', value);

  String? get gioiTinh => _currentUser?['GioiTinh'];
  set gioiTinh(String? value) => _setUserField('GioiTinh', value);

  String? get ngaySinh => _currentUser?['Birthday'];
  set ngaySinh(String? value) => _setUserField('Birthday', value);

  // Điểm tích luỹ
  int get diemTichLuy => _currentUser?['DiemTichLuy'] ?? 0;
  int get tongDiemTichLuy => _currentUser?['tongDiemTichLuy'] ?? 0;
  String get capDo => _currentUser?['capDo'] ?? 'Mới';

  void _setUserField(String key, dynamic value) {
    _currentUser ??= {};
    _currentUser![key] = value;
  }

  // ---------------------------------------------------------------------------
  // 3. SESSION HANDLER
  // ---------------------------------------------------------------------------

  Future<String> getToken() async {
    if (_currentUser == null) await loadUser();
    return accessToken ?? '';
  }

  Future<void> saveUser(Map<String, dynamic> userData) async {
    _currentUser = userData;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_session', jsonEncode(userData));

    debugPrint("UserManager: Session saved - ${userData['HoTen']}");
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('user_session');

    if (data != null) {
      try {
        _currentUser = jsonDecode(data);
        debugPrint("UserManager: Session restored - ${_currentUser?['HoTen']}");
      } catch (e) {
        debugPrint("UserManager: Session parse error: $e");
        await logout();
      }
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('user_session');
    debugPrint("UserManager: Logged out.");
  }

  // ---------------------------------------------------------------------------
  // 4. UPDATE USER FIELDS (VD: Cập nhật điểm)
  // ---------------------------------------------------------------------------

  Future<void> updateDiem(int diemMoi, {int? tongDiemMoi}) async {
    if (_currentUser == null) return;

    _currentUser!['DiemTichLuy'] = diemMoi;
    if (tongDiemMoi != null) {
      _currentUser!['tongDiemTichLuy'] = tongDiemMoi;
    }

    await saveUser(_currentUser!);
    debugPrint("UserManager: Updated points = $diemMoi");
  }
}
