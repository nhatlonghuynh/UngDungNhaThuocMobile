import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/UI/common/utils/dialog_helper.dart';
import 'package:nhathuoc_mobilee/controller/cartcontroller.dart';

class CartItemWidget extends StatelessWidget {
  final int index;
  final CartController controller;

  const CartItemWidget({
    super.key,
    required this.index,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // Kiểm tra an toàn
    if (index >= controller.cartItems.length) return const SizedBox();

    final item = controller.cartItems[index];
    final formatter = NumberFormat('#,###', 'vi_VN');

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutralGrey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // -----------------------------------------------------------
          // LAYER 1: NỘI DUNG CHÍNH
          // -----------------------------------------------------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Checkbox (ĐÃ SỬA: Gọi Controller để update Tổng tiền)
              Padding(
                padding: const EdgeInsets.only(right: 0),
                child: Transform.scale(
                  scale: 1.1,
                  child: Checkbox(
                    value: item.isSelected,
                    activeColor: AppColors.primaryPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: const BorderSide(
                      color: AppColors.neutralGrey,
                      width: 1.2,
                    ),
                    onChanged: (val) {
                      // Gọi hàm toggleItem vừa thêm ở Bước 1
                      controller.toggleItem(index);
                    },
                  ),
                ),
              ),

              // 2. Ảnh thuốc
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  item.anhURL,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[100],
                    width: 80,
                    height: 80,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // 3. Cột thông tin
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 30.0),
                      child: Text(
                        item.tenThuoc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textBrown,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Đơn vị: ${item.donVi}",
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    const SizedBox(height: 8),

                    // --- GIÁ & SỐ LƯỢNG ---
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      runSpacing: 5,
                      children: [
                        Text(
                          "${formatter.format(item.donGia)}đ",
                          style: const TextStyle(
                            color: AppColors.secondaryGreen,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),

                        // Bộ điều khiển số lượng (ĐÃ SỬA: Xóa onRefresh)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _qtyBtn(Icons.remove, () {
                                controller.updateQuantity(index, -1);
                              }),
                              Container(
                                constraints: const BoxConstraints(minWidth: 24),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Text(
                                  "${item.soLuong}",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textBrown,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              _qtyBtn(Icons.add, () {
                                controller.updateQuantity(index, 1);
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // -----------------------------------------------------------
          // LAYER 2: NÚT XÓA (ĐÃ SỬA: Xóa onRefresh)
          // -----------------------------------------------------------
          Positioned(
            top: -5,
            right: -5,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () async {
                  final confirm = await DialogHelper.showConfirmDialog(
                    context,
                    title: "Xóa sản phẩm",
                    content: "Bạn muốn xóa ${item.tenThuoc} khỏi giỏ hàng?",
                    confirmText: "Xóa",
                  );
                  if (confirm == true) {
                    controller.deleteItem(index);
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.close, color: Colors.grey, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Icon(icon, size: 16, color: AppColors.textBrown),
      ),
    );
  }
}
