import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhathuoc_mobilee/controller/cartcontroller.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';

class CartBottomBar extends StatelessWidget {
  final CartController controller;
  // Đã xóa: final VoidCallback onRefresh; -> Không cần nữa
  final VoidCallback onCheckout;

  const CartBottomBar({
    super.key,
    required this.controller,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'vi_VN');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutralGrey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 1. Checkbox "Tất cả"
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: controller.isAllSelected,
                    activeColor: AppColors.primaryPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (val) {
                      // Chỉ cần gọi hàm controller, UI tự cập nhật
                      controller.toggleSelectAll(val ?? false);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Tất cả",
                  style: TextStyle(
                    color: AppColors.textBrown,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            // 2. Tổng tiền
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Tổng thanh toán",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.neutralBeige,
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        "${formatter.format(controller.totalPayment)}đ",
                        style: const TextStyle(
                          color: AppColors.primaryPink,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Nút Mua hàng
            ElevatedButton(
              onPressed: controller.totalPayment > 0 ? onCheckout : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                elevation: 4,
              ),
              child: const Text(
                "Mua hàng",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
