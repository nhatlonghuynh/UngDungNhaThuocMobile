import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/controller/productcontroller.dart';

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
      padding: const EdgeInsets.all(16),
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
        // Dùng SizedBox với width: double.infinity để nút tràn chiều ngang
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isOutOfStock
                  ? Colors.grey
                  : AppColors.primaryPink,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            onPressed: isOutOfStock ? null : onAddToCart,
            child: Text(
              isOutOfStock ? "HẾT HÀNG" : "Chọn mua", // Đã đổi text
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
