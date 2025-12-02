import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/api_constants.dart';
import 'package:nhathuoc_mobilee/controller/rewardcontroller.dart';
import 'package:nhathuoc_mobilee/service/rewardservice.dart';
import 'package:nhathuoc_mobilee/manager/usermanager.dart';
import 'package:nhathuoc_mobilee/UI/common/utils/dialog_helper.dart'; // [DRY]

class RewardGiftCard extends StatelessWidget {
  final GiftModel gift;
  final RewardController controller;

  const RewardGiftCard({
    super.key,
    required this.gift,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // Logic kiểm tra điều kiện
    bool isOutOfStock = gift.quantity <= 0; // Hết hàng
    bool notEnoughPoints = UserManager().diemTichLuy < gift.points;
    bool canRedeem = !isOutOfStock && !notEnoughPoints;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          // ignore: deprecated_member_use
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5),
        ],
      ),
      child: Column(
        children: [
          // --- XỬ LÝ ẢNH (QUAN TRỌNG) ---
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child: _buildGiftImage(gift.imagePath),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  gift.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "${gift.points} điểm",
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Hiển thị tồn kho (Optional)
                if (isOutOfStock)
                  const Text(
                    "(Hết hàng)",
                    style: TextStyle(color: Colors.red, fontSize: 10),
                  ),

                const SizedBox(height: 5),

                // --- NÚT BẤM ---
                SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: ElevatedButton(
                    // Nếu hết hàng hoặc thiếu điểm thì disable nút
                    onPressed: canRedeem ? () => _confirmRedeem(context) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canRedeem
                          ? Colors.green
                          : Colors.grey[300],
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isOutOfStock
                          ? "Hết hàng"
                          : (notEnoughPoints ? "Thiếu điểm" : "Đổi ngay"),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftImage(String path) {
    if (path.startsWith("http")) {
      return Image.network(path, fit: BoxFit.cover);
    } else if (path.contains("images/")) {
      String cleanPath = path.startsWith('/') ? path.substring(1) : path;
      String fullUrl = "${ApiConstants.serverUrl}/$cleanPath";
      return Image.network(
        fullUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
      );
    }
    return Image.asset(
      "assets/images/default_gift.png",
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const Icon(Icons.image),
    );
  }

  // Logic đổi quà
  void _confirmRedeem(BuildContext context) async {
    // 1. Dialog Xác nhận (Dùng Helper)
    final confirm = await DialogHelper.showConfirmDialog(
      context,
      title: "Xác nhận đổi quà",
      content: "Dùng ${gift.points} điểm để đổi '${gift.name}'?",
      confirmText: "Đổi ngay",
      confirmColor: Colors.green,
    );

    if (confirm != true) return;

    // 2. Gọi API (Hiện Loading)
    if (!context.mounted) return;

    // Hiển thị Loading (Tự tạo dialog loading đơn giản hoặc dùng helper nếu có)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final result = await controller.exchangeGift(gift);

    if (context.mounted) Navigator.pop(context); // Tắt loading

    // 3. Thông báo kết quả
    if (context.mounted) {
      if (result['success']) {
        DialogHelper.showSuccessDialog(
          context,
          title: "Thành công!",
          message: result['message'],
        );
      } else {
        DialogHelper.showError(context, message: result['message']);
      }
    }
  }
}
