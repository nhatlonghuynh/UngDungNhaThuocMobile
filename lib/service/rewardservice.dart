import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:nhathuoc_mobilee/api/rewardapi.dart';
import 'package:nhathuoc_mobilee/manager/usermanager.dart';

// Model Gift (Giữ nguyên, thêm debugPrint nếu cần check parse)
class GiftModel {
  final int id;
  final String name;
  final int points;
  final String imagePath;
  final int quantity;

  GiftModel({
    required this.id,
    required this.name,
    required this.points,
    required this.imagePath,
    required this.quantity,
  });

  factory GiftModel.fromJson(Map<String, dynamic> json) {
    return GiftModel(
      id: json['Id'] ?? 0,
      name: json['TenQua'] ?? '',
      points: json['DiemCanDoi'] ?? 0,
      imagePath: json['AnhMinhHoa'] ?? "assets/images/promotion/voucher20.png",
      quantity: json['SoLuongTon'] ?? 0,
    );
  }
}

class RewardService {
  final RewardRepository _repo = RewardRepository();

  // 1. Lấy danh sách
  Future<List<GiftModel>> getGifts() async {
    try {
      debugPrint("🎁 [Service] Fetching gifts...");
      final response = await _repo.fetchGiftsRequest();

      debugPrint("⬅️ [Service] Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        // Decode UTF8 cho tiếng Việt
        List<dynamic> list = jsonDecode(utf8.decode(response.bodyBytes));
        debugPrint("✅ [Service] Loaded ${list.length} gifts");
        return list.map((e) => GiftModel.fromJson(e)).toList();
      } else {
        throw Exception("Lỗi tải danh sách: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ [Service] Error: $e");
      throw Exception("Lỗi kết nối: $e");
    }
  }

  // 2. Đổi quà
  // 2. Đổi quà
  Future<Map<String, dynamic>> redeemGift({
    required int giftId,
    int points = 0,
    // Các tham số khác như name, points, type không cần gửi lên server nữa
  }) async {
    try {
      final user = UserManager();
      debugPrint("🎁 [Service] Redeeming ID: $giftId");

      // Body chỉ cần gửi đúng 2 thông tin này
      final body = {"MaKH": user.userId, "MaQua": giftId};

      final response = await _repo.redeemGiftRequest(body);

      // Decode để đọc tiếng Việt trong message lỗi/thành công
      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        // Cập nhật điểm mới
        int newPoints = data['DiemConLai'] ?? (user.diemTichLuy - points);
        await user.updateDiem(newPoints);

        debugPrint("✅ [Service] Success! New Points: $newPoints");
        return {'success': true, 'message': 'Đổi quà thành công!'};
      } else {
        String msg = data['Message'] ?? "Đổi quà thất bại";
        debugPrint("❌ [Service] Fail: $msg");
        return {'success': false, 'message': msg};
      }
    } catch (e) {
      debugPrint("❌ [Service] Exception: $e");
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
}
