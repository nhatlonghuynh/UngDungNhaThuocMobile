import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';

// --- HELPER PHÂN MÀU (Giữ logic cũ + thêm màu mới) ---
class StatusHelper {
  static Color getColor(String status) {
    // Chuyển về chữ thường để so sánh cho chính xác
    final s = status.toLowerCase();

    if (s.contains('chờ')) {
      return Colors.orange.shade700; // Màu cam
    } else if (s.contains('đang giao')) {
      return Colors.blue.shade600; // Màu xanh dương
    } else if (s.contains('đã giao') || s.contains('hoàn thành')) {
      return Colors.green.shade600; // Màu xanh lá
    } else if (s.contains('hủy')) {
      return Colors.red.shade600; // Màu đỏ
    }
    return Colors.teal; // Màu mặc định cũ của bạn
  }
}

class OrderHistoryCard extends StatelessWidget {
  // GIỮ NGUYÊN: dynamic order theo ý bạn
  final dynamic order;
  final VoidCallback onTap;

  const OrderHistoryCard({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    // Định dạng ngày (lưu ý: đảm bảo order.ngayTao là kiểu DateTime, nếu là String thì cần parse)
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    // Lấy màu từ Helper dựa trên order.trangThai
    final statusColor = StatusHelper.getColor(order.trangThai);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header: Mã đơn + Trạng thái
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "#${order.maHD}", // Giữ tên biến maHD
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  // Badge trạng thái có màu
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1), // Màu nền nhạt
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      order.trangThai, // Giữ tên biến trangThai
                      style: TextStyle(
                        color: statusColor, // Màu chữ đậm
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // 2. Ngày đặt (Icon + Text)
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    // Giữ tên biến ngayTao
                    // Lưu ý: Nếu order.ngayTao là null thì hiển thị text mặc định để ko lỗi
                    order.ngayTao != null
                        ? dateFormat.format(order.ngayTao)
                        : "Không xác định",
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const Divider(height: 24, thickness: 0.5),

              // 3. Thông tin sản phẩm đại diện
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.medication_liquid_outlined,
                      size: 24,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.tenThuocDau ??
                              "Sản phẩm", // Giữ tên biến tenThuocDau
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "x${order.soLuongThuocDau ?? 1} sản phẩm đầu tiên...", // Giữ tên biến soLuongThuocDau
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 4. Tổng tiền
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    "Thành tiền: ",
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    currencyFormat.format(
                      order.tongTien,
                    ), // Giữ tên biến tongTien
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
