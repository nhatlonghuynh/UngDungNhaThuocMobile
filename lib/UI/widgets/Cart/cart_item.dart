import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/UI/common/utils/dialog_helper.dart';
import 'package:nhathuoc_mobilee/controller/cartcontroller.dart';

class CartItemWidget extends StatelessWidget {
  final int index;
  final CartController controller;
  final VoidCallback onRefresh;

  const CartItemWidget({
    super.key,
    required this.index,
    required this.controller,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    // Kiểm tra an toàn: Nếu index vượt quá độ dài list (do xóa nhanh quá), return rỗng
    if (index >= controller.cartItems.length) return const SizedBox();

    final item = controller.cartItems[index];
    final formatter = NumberFormat('#,###', 'vi_VN');

    return Container(
      // margin: const EdgeInsets.only(bottom: 16), // Bật lên nếu muốn các item cách xa nhau
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutralGrey.withOpacity(
              0.15,
            ), // Giảm shadow xíu cho nhẹ
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // -----------------------------------------------------------
          // LAYER 1: NỘI DUNG CHÍNH (Checkbox - Ảnh - Thông tin)
          // -----------------------------------------------------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Checkbox
              Padding(
                padding: const EdgeInsets.only(
                  right: 0,
                ), // Tinh chỉnh khoảng cách nếu cần
                child: Transform.scale(
                  scale: 1.1, // Scale nhỏ lại xíu cho tinh tế
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
                      item.isSelected = val ?? false;
                      onRefresh();
                    },
                  ),
                ),
              ),

              // 2. Ảnh thuốc
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  item.anhURL,
                  width: 80, // Giảm nhẹ xuống 80 để tiết kiệm không gian ngang
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

              // 3. Cột thông tin (Dùng Expanded để chiếm phần còn lại)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên thuốc: Padding phải 30px để né nút Xóa ở góc
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
                          height: 1.2, // Tăng độ thoáng dòng
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "Đơn vị: ${item.donVi}",
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),

                    const SizedBox(height: 8),

                    // --- KHU VỰC "GIÁ & SỐ LƯỢNG" (Dùng Wrap là chuẩn nhất) ---
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10, // Khoảng cách ngang giữa Giá và Nút
                      runSpacing: 5, // Khoảng cách dọc nếu bị rớt dòng
                      children: [
                        // Giá tiền
                        Text(
                          "${formatter.format(item.donGia)}đ",
                          style: const TextStyle(
                            color: AppColors.secondaryGreen,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                          overflow:
                              TextOverflow.ellipsis, // Đề phòng giá quá dài
                        ),

                        // Bộ điều khiển số lượng
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50], // Màu nền nhẹ
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize
                                .min, // Quan trọng: Co lại vừa đủ nội dung
                            children: [
                              _qtyBtn(Icons.remove, () async {
                                await controller.updateQuantity(index, -1);
                                onRefresh();
                              }),

                              // Số lượng (Dùng Container + ConstrainedBox để an toàn)
                              Container(
                                constraints: const BoxConstraints(
                                  minWidth: 24,
                                ), // Chiều rộng tối thiểu
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

                              _qtyBtn(Icons.add, () async {
                                await controller.updateQuantity(index, 1);
                                onRefresh();
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
          // LAYER 2: NÚT XÓA (Nằm đè lên trên cùng, góc phải)
          // -----------------------------------------------------------
          Positioned(
            top: -5, // Đẩy lên cao một chút để cân đối
            right: -5, // Đẩy sang phải sát lề
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
                    await controller.deleteItem(index);
                    onRefresh();
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0), // Vùng bấm rộng dễ thao tác
                  child: Icon(
                    Icons.close, // Dùng icon close hoặc delete_outline đều đẹp
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget con cho nút cộng trừ
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
