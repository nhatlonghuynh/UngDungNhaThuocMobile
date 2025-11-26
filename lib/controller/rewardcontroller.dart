import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/manager/usermanager.dart';
import 'package:nhathuoc_mobilee/service/rewardservice.dart';

class RewardController extends ChangeNotifier {
  final RewardService _service = RewardService();

  // State
  List<GiftModel> gifts = [];
  bool isLoading = false;
  String? errorMessage;

  /// Tải danh sách quà tặng
  Future<void> loadGifts() async {
    if (!UserManager().isLoggedIn) return;

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      gifts = await _service.getGifts();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Thực hiện đổi quà
  Future<Map<String, dynamic>> exchangeGift(GiftModel gift) async {
    try {
      final result = await _service.redeemGift(
        giftId: gift.id,
        name: gift.name,
        points: gift.points,
        type: gift.type,
      );

      // Nếu thành công, UserManager đã cập nhật điểm, cần báo UI refresh
      if (result['success'] == true) {
        notifyListeners();
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Lỗi đổi quà: $e'};
    }
  }
}
