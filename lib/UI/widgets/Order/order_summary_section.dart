import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/controller/ordercontroller.dart';
import 'package:nhathuoc_mobilee/models/giohang.dart';

class OrderSummarySection extends StatelessWidget {
  final OrderController controller;
  final List<GioHang> selectedItems;

  const OrderSummarySection({
    super.key,
    required this.controller,
    required this.selectedItems,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Chi tiết thanh toán",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 15),
          _buildRow(
            "Tạm tính",
            controller.getSubtotal(selectedItems),
            formatter,
          ),
          _buildRow("Phí vận chuyển", controller.getShipping(), formatter),
          if (controller.getPointDiscount() > 0)
            _buildRow(
              "Giảm giá (Điểm)",
              -controller.getPointDiscount(),
              formatter,
              color: Colors.green,
            ),

          const Divider(height: 30),

          _buildRow(
            "Tổng thanh toán",
            controller.getFinalTotal(selectedItems),
            formatter,
            isBold: true,
            color: AppColors.primaryPink,
            fontSize: 20,
          ),

          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "+ Tích lũy: ${controller.getEarnedPoints(selectedItems)} điểm",
              style: TextStyle(
                color: Colors.orange[700],
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    String label,
    double val,
    NumberFormat fmt, {
    bool isBold = false,
    Color? color,
    double fontSize = 14,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: AppColors.textBrown,
            ),
          ),
          Text(
            "${fmt.format(val)}đ",
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? AppColors.textBrown,
            ),
          ),
        ],
      ),
    );
  }
}
