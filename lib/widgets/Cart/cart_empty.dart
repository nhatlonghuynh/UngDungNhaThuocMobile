import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/common/constants/appcolor.dart';

class CartEmptyWidget extends StatelessWidget {
  const CartEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 100, color: AppColors.neutralGrey.withOpacity(0.5)),
          const SizedBox(height: 20),
          const Text("Giỏ hàng trống", style: TextStyle(fontSize: 18, color: AppColors.textBrown, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}