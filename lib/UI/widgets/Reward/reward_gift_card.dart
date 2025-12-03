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
    // Show a bottom sheet with points breakdown (current, cost, remaining)
    final int currentPoints = UserManager().diemTichLuy;
    final int cost = gift.points;
    final int remaining = currentPoints - cost;

    final bool? confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.36,
          minChildSize: 0.22,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.only(
                top: 12,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const Text(
                      "Xác nhận đổi quà",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      gift.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Điểm hiện có",
                          style: TextStyle(color: Colors.black54),
                        ),
                        Text(
                          "$currentPoints",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Điểm cần đổi",
                          style: TextStyle(color: Colors.black54),
                        ),
                        Text(
                          "$cost",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Điểm còn lại",
                          style: TextStyle(color: Colors.black54),
                        ),
                        Text(
                          "$remaining",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'HỦY',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'ĐỔI NGAY',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (confirmed != true) return;

    // Proceed with API call (show loading and call controller.exchangeGift)
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final result = await controller.exchangeGift(gift);

    if (context.mounted) Navigator.pop(context); // close loading

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
