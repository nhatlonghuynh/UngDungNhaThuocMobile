import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/UI/common/utils/color_opacity_ext.dart';
import 'package:nhathuoc_mobilee/controller/productcontroller.dart';
import 'package:nhathuoc_mobilee/service/productservice.dart';

class ProductBottomBar extends StatelessWidget {
  final ProductDetailController controller;
  final VoidCallback onAddToCart;

  const ProductBottomBar({
    super.key,
    required this.controller,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final product = controller.product!;
    bool isOutOfStock = product.soLuong <= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Price + stock info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ProductService.formatMoney(controller.finalPrice) + 'đ',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isOutOfStock
                        ? 'Hết hàng'
                        : 'Còn ${product.soLuong} trên kệ',
                    style: TextStyle(
                      color: isOutOfStock
                          ? Colors.red.shade400
                          : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // CTA button
            SizedBox(
              width: 160,
              child: ElevatedButton.icon(
                onPressed: isOutOfStock ? null : onAddToCart,
                icon: const Icon(Icons.add_shopping_cart),
                label: Text(isOutOfStock ? 'HẾT HÀNG' : 'Chọn mua'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOutOfStock
                      ? Colors.grey
                      : AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 6,
                  shadowColor: (isOutOfStock ? Colors.grey : AppColors.primary)
                      .withOpacity(0.32),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
