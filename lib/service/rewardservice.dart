import 'dart:convert';
import 'package:nhathuoc_mobilee/api/rewardapi.dart';
import 'package:nhathuoc_mobilee/manager/usermanager.dart';

// Model Gift (Đặt ở đây hoặc tách file riêng tùy bạn)
class GiftModel {
  final int id;
  final String name;
  final int points;
  final String imagePath;
  final String type;

  GiftModel({
    required this.id,
    required this.name,
    required this.points,
    required this.imagePath,
    required this.type,
  });

  factory GiftModel.fromJson(Map<String, dynamic> json) {
    return GiftModel(
      id: json['Id'],
      name: json['TenQua'],
      points: json['DiemCanDoi'],
      // API trả về đường dẫn hoặc null thì lấy ảnh mặc định
      imagePath: json['AnhMinhHoa'] ?? "assets/images/voucher20.png",
      type: json['LoaiQua'],
    );
  }
}

class RewardService {
  final RewardRepository _repo = RewardRepository();

  // 1. Lấy danh sách và parse sang List<GiftModel>
  Future<List<GiftModel>> getGifts() async {
    try {
      final response = await _repo.fetchGiftsRequest();

      if (response.statusCode == 200) {
        List<dynamic> list = jsonDecode(response.body);
        return list.map((e) => GiftModel.fromJson(e)).toList();
      } else {
        throw Exception("Lỗi tải danh sách: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Lỗi kết nối: $e");
    }
  }

  // 2. Xử lý đổi quà và CẬP NHẬT ĐIỂM
  Future<Map<String, dynamic>> redeemGift({
    required int giftId,
    required String name,
    required int points,
    required String type,
  }) async {
    try {
      final user = UserManager();

      // Tạo body gửi lên server
      final body = {
        "MaKH": user.userId,
        "MaQua": giftId,
        "TenQua": name,
        "DiemTieuTon": points,
        "LoaiQua": type,
      };

      final response = await _repo.redeemGiftRequest(body);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // --- QUAN TRỌNG: API trả về điểm còn lại -> Cập nhật ngay vào App ---
        int newPoints = data['DiemConLai'];
        await user.updateDiem(newPoints);

        return {'success': true, 'message': 'Đổi quà thành công!'};
      } else {
        // Xử lý lỗi từ Server trả về (VD: Không đủ điểm)
        String msg = data['Message'] ?? "Đổi quà thất bại";
        return {'success': false, 'message': msg};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
}
