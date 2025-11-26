import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/controller/rewardcontroller.dart';
import 'package:nhathuoc_mobilee/service/rewardservice.dart';
import 'package:nhathuoc_mobilee/manager/usermanager.dart';
import 'package:nhathuoc_mobilee/common/utils/dialog_helper.dart'; // [DRY]

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
    bool canRedeem = UserManager().diemTichLuy >= gift.points;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5),
        ],
      ),
      child: Column(
        children: [
          // Ảnh quà
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child: Image.asset(
                gift.imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.image_not_supported,
                  color: AppColors.neutralGrey,
                ),
              ),
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
                const SizedBox(height: 5),

                // Nút Đổi Ngay
                SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: ElevatedButton(
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
                      canRedeem ? "Đổi ngay" : "Thiếu điểm",
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
