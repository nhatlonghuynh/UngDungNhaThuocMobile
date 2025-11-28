import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/manager/usermanager.dart';
import 'package:nhathuoc_mobilee/service/rewardservice.dart';

class RewardController extends ChangeNotifier {
  final RewardService _service = RewardService();

  List<GiftModel> gifts = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadGifts() async {
    if (!UserManager().isLoggedIn) return;

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      debugPrint("🎮 [Controller] Loading Gifts...");
      gifts = await _service.getGifts();
    } catch (e) {
      errorMessage = e.toString();
      debugPrint("❌ [Controller] Load Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> exchangeGift(GiftModel gift) async {
    try {
      final result = await _service.redeemGift(
        giftId: gift.id,
        name: gift.name,
        points: gift.points,
        type: gift.type,
      );

      if (result['success'] == true) {
        notifyListeners(); // Refresh UI để cập nhật số điểm hiển thị
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Lỗi đổi quà: $e'};
    }
  }
}
