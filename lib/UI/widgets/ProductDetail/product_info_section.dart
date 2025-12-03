import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/models/thuoc_detail.dart';

class ProductInfoSection extends StatelessWidget {
  final ThuocDetail product;
  final double finalPrice;

  const ProductInfoSection({
    super.key,
    required this.product,
    required this.finalPrice,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tên thuốc
          Text(
            product.tenThuoc,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          // --- SỬA Ở ĐÂY: Thay Row bằng Wrap ---
          Wrap(
            crossAxisAlignment:
                WrapCrossAlignment.center, // Canh giữa theo chiều dọc
            spacing: 10, // Khoảng cách ngang (thay cho SizedBox width)
            runSpacing: 4, // Khoảng cách dọc (nếu bị rớt dòng)
            children: [
              Text(
                "${currencyFormat.format(finalPrice)} / ${product.donVi}",
                style: const TextStyle(
                  fontSize: 24,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (product.khuyenMai != null)
                Text(
                  currencyFormat.format(product.giaBan),
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
            ],
          ),

          // --------------------------------------
          const Divider(height: 30),

          // Thông tin chi tiết
          _buildInfoRow(Icons.business, "Thương hiệu", product.tenNCC),
          _buildInfoRow(Icons.medication, "Công dụng", product.congDung),
          _buildInfoRow(Icons.science, "Thành phần", product.thanhPhan),
          _buildInfoRow(Icons.info_outline, "Cách dùng", product.cachSD),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SelectableText(
            content,
            style: const TextStyle(color: Colors.black87, height: 1.5),
          ),
        ],
      ),
    );
  }
}
