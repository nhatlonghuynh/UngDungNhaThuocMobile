import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/UI/screens/detail_product_screen.dart';

class OrderDetailProductList extends StatelessWidget {
  final List<dynamic> products;
  final double totalPrice;

  const OrderDetailProductList({
    super.key,
    required this.products,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Danh sách sản phẩm",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),

        // List sản phẩm
        ...products.map(
          (item) => Padding(
            // [SỬA 1] Chuyển margin ra ngoài để InkWell/GestureDetector hoạt động đúng layout
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              // [SỬA 2] Thêm sự kiện onTap
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // [LƯU Ý] Kiểm tra kỹ tên trường ID trong model của bạn là 'maSP', 'maThuoc' hay 'id'
                    builder: (_) =>
                        DetailProductScreen(productId: item.maThuoc),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.border.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    // Ảnh hoặc Icon thuốc
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      // Nếu item có ảnh (item.anh) thì nên hiển thị ảnh, nếu không thì hiện Icon
                      child: const Icon(
                        Icons.medical_services_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Thông tin tên và giá
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.tenThuoc ?? "Tên thuốc",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${currencyFormat.format(item.donGia)} x ${item.soLuong}",
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Thành tiền
                    Text(
                      currencyFormat.format(item.thanhTien),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 15),

        // Tổng tiền
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Tổng thanh toán:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                currencyFormat.format(totalPrice),
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
