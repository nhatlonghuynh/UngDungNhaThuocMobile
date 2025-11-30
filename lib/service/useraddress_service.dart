import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:nhathuoc_mobilee/api/userapi.dart';
import 'package:nhathuoc_mobilee/models/diachikhachhang.dart';

class UserAddressService {
  final ProfileRepository _repo = ProfileRepository();

  // =======================================================================
  // 1. LẤY DANH SÁCH ĐỊA CHỈ
  // =======================================================================
  Future<List<UserAddress>> getAddresses(String userId) async {
    try {
      debugPrint("📍 [AddressService] GET All: $userId");
      final response = await _repo.getAddressesRequest(userId);
      debugPrint("🔍 [DEBUG] Status: ${response.statusCode}");
      debugPrint("🔍 [DEBUG] Body: ${response.body}");
      if (response.statusCode == 200) {
        // Decode UTF8 cho chắc chắn
        List data = json.decode(utf8.decode(response.bodyBytes));
        debugPrint("📍 [AddressService] Found ${data.length} addresses");
        return data.map((e) => UserAddress.fromJson(e)).toList();
      } else {
        final error = _handleError(response);
        throw Exception(error['message']);
      }
    } catch (e) {
      debugPrint("❌ [AddressService] Get Error: $e");
      throw Exception("Lỗi kết nối: $e");
    }
  }

  // =======================================================================
  // 2. THÊM ĐỊA CHỈ (QUAN TRỌNG: TRẢ VỀ ID THẬT)
  // =======================================================================
  Future<int> addAddress(String userId, UserAddress addr) async {
    try {
      debugPrint("➕ [AddressService] Adding: ${addr.street}...");

      final response = await _repo.addAddressRequest(userId, addr.toJson());

      debugPrint("⬅️ [AddressService] Status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);

        // Logic tìm ID thật trong response trả về từ Server
        // Case 1: Trả về object { "addressID": 105, ... }
        if (body is Map) {
          if (body.containsKey('ID')) return body['ID'];
          if (body.containsKey('addressID')) return body['addressID'];
          if (body.containsKey('id')) return body['id'];
        }
        // Case 2: Trả về số nguyên trực tiếp: 105
        if (body is int) return body;

        return 0; // Không tìm thấy ID
      } else {
        final error = _handleError(response);
        throw Exception(error['message']);
      }
    } catch (e) {
      debugPrint("❌ [AddressService] Add Error: $e");
      throw Exception("Lỗi thêm địa chỉ: $e");
    }
  }

  // =======================================================================
  // 3. CẬP NHẬT ĐỊA CHỈ
  // =======================================================================
  Future<void> updateAddress(UserAddress addr) async {
    try {
      debugPrint("✏️ [AddressService] Update ID: ${addr.addressID}");
      final response = await _repo.updateAddressRequest(
        addr.addressID,
        addr.toJson(),
      );

      if (response.statusCode != 200) {
        final error = _handleError(response);
        throw Exception(error['message']);
      }
    } catch (e) {
      throw Exception("Lỗi sửa địa chỉ: $e");
    }
  }

  // =======================================================================
  // 4. XÓA ĐỊA CHỈ
  // =======================================================================
  Future<void> deleteAddress(int addressID) async {
    try {
      debugPrint("🗑️ [AddressService] Delete ID: $addressID");
      final response = await _repo.deleteAddressRequest(addressID);

      if (response.statusCode != 200 && response.statusCode != 204) {
        final error = _handleError(response);
        throw Exception(error['message']);
      }
    } catch (e) {
      throw Exception("Lỗi xóa địa chỉ: $e");
    }
  }

  // Helper xử lý lỗi (Duplicate code 1 chút nhưng giúp tách biệt hoàn toàn 2 file)
  Map<String, dynamic> _handleError(http.Response response) {
    try {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      String msg = data['message'] ?? "Lỗi server (${response.statusCode}): ${response.body}";
      if (data['ModelState'] != null) {
        msg = data['ModelState'].values.first[0];
      }
      return {'success': false, 'message': msg};
    } catch (_) {
      return {
        'success': false,
        'message': 'Lỗi server (${response.statusCode}): ${response.body}',
      };
    }
  }
}
