import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserManager {
  // ---------------------------------------------------------------------------
  // 1. SINGLETON
  // ---------------------------------------------------------------------------
  static final UserManager _instance = UserManager._internal();
  factory UserManager() => _instance;
  UserManager._internal();

  // Biến lưu user trên RAM
  Map<String, dynamic>? _currentUser;

  // KEY LƯU TRỮ (Khai báo 1 lần duy nhất)
  static const String _storageKey = 'user_session';

  // Secure Storage
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

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
  // Lưu ý: Số điện thoại thường là key định danh, hạn chế set lại trừ khi có luồng đổi SĐT
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
  String get capDo => _currentUser?['capDo'] ?? 'Thành viên';

  // Helper set data & tự động lưu xuống đĩa
  void _setUserField(String key, dynamic value) {
    if (_currentUser != null) {
      _currentUser![key] = value;
      saveUser(_currentUser!); // Tự động lưu ngay khi set giá trị
    }
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
    // Lưu vào Secure Storage
    await _storage.write(key: _storageKey, value: jsonEncode(userData));

    debugPrint("👤 [UserMgr] Session saved (Secure): ${userData['HoTen']}");
  }

  Future<void> loadUser() async {
    // Đọc từ Secure Storage
    final data = await _storage.read(key: _storageKey);

    if (data != null) {
      try {
        _currentUser = jsonDecode(data);
        debugPrint("👤 [UserMgr] Session restored: ${_currentUser?['HoTen']}");
      } catch (e) {
        debugPrint("❌ [UserMgr] Parse error: $e");
        await logout();
      }
    } else {
      debugPrint("👤 [UserMgr] No session found");
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await _storage.delete(key: _storageKey);
    debugPrint("👋 [UserMgr] Logged out (Secure)");
  }

  // ---------------------------------------------------------------------------
  // 4. UPDATE USER FIELDS (Cập nhật điểm)
  // ---------------------------------------------------------------------------

  Future<void> updateDiem(int diemMoi, {int? tongDiemMoi}) async {
    if (_currentUser == null) return;

    _currentUser!['DiemTichLuy'] = diemMoi;
    if (tongDiemMoi != null) {
      _currentUser!['tongDiemTichLuy'] = tongDiemMoi;
    }

    await saveUser(_currentUser!);
    debugPrint("💎 [UserMgr] Updated Points: $diemMoi");
  }
}
