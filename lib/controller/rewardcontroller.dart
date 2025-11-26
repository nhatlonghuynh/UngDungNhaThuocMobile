import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/manager/usermanager.dart';
import 'package:nhathuoc_mobilee/service/rewardservice.dart';

class RewardController extends ChangeNotifier {
  final RewardService _service = RewardService();

  List<GiftModel> gifts = [];
  bool isLoading = false;
  String? errorMessage;

  // Hàm tải danh sách quà
  Future<void> loadGifts() async {
    // Nếu chưa đăng nhập thì không tải
    if (!UserManager().isLoggedIn) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      gifts = await _service.getGifts();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Hàm đổi quà
  Future<Map<String, dynamic>> exchangeGift(GiftModel gift) async {
    // Gọi Service đổi quà
    final result = await _service.redeemGift(
      giftId: gift.id,
      name: gift.name,
      points: gift.points,
      type: gift.type,
    );

    // Nếu thành công, notifyListeners để UI cập nhật lại số điểm (vì UserManager đã thay đổi)
    if (result['success'] == true) {
      notifyListeners();
    }

    return result;
  }
}
