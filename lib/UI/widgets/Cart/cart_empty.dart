import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/UI/common/widget/empty_state.dart';

class CartEmptyWidget extends StatelessWidget {
  const CartEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      title: "Giỏ hàng trống",
      subtitle: "Thêm sản phẩm vào giỏ hàng để bắt đầu mua sắm",
      icon: Icons.shopping_cart_outlined,
      iconColor: AppColors.primary,
    );
  }
}
