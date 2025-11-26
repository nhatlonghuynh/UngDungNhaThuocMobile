import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/common/constants/appcolor.dart';

class OrderDetailInfoCard extends StatelessWidget {
  final String title;
  final List<Map<String, String>> items; // Danh sách key-value: "Ngày đặt": "20/10/2023"

  const OrderDetailInfoCard({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutralGrey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColors.primaryPink, // Hoặc màu Teal tuỳ bạn
            ),
          ),
          const Divider(height: 20, thickness: 0.5),
          ...items.map((item) => _buildRow(item.keys.first, item.values.first)),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.neutralGrey, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: AppColors.textBrown,
              ),
            ),
          ),
        ],
      ),
    );
  }
}