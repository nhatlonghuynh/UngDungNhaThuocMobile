import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/controller/historyordercontroller.dart';
import 'package:nhathuoc_mobilee/UI/widgets/HistoryOrder/order_detail_info_card.dart';
import 'package:nhathuoc_mobilee/UI/widgets/HistoryOrder/order_detail_product_list.dart';
import 'package:nhathuoc_mobilee/UI/common/widget/loading_state.dart';
import 'package:nhathuoc_mobilee/UI/common/widget/error_state.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderHistoryController>().getOrderDetail(widget.orderId);
    });
  }

  //Xác nhận đơn hàng
  void _onConfirmReceived() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận nhận hàng"),
        content: const Text(
          "Bạn xác nhận đã nhận được đầy đủ hàng và muốn hoàn tất đơn hàng này?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Đóng", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              Navigator.pop(ctx);
              // Gọi Controller
              context
                  .read<OrderHistoryController>()
                  .confirmReceived(widget.orderId)
                  .then((success) {
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Đã xác nhận nhận hàng thành công!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  });
            },
            child: const Text(
              "Đã nhận hàng",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // [CHỨC NĂNG MỚI] Xử lý sự kiện hủy đơn
  void _onCancelOrder() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "Xác nhận hủy",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Bạn có chắc chắn muốn hủy đơn hàng này không?\nHành động này không thể hoàn tác.",
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Đóng", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              // Gọi API hủy trong Controller
              context
                  .read<OrderHistoryController>()
                  .cancelOrder(widget.orderId)
                  .then((success) {
                    if (success) {
                      // Reload lại data để cập nhật trạng thái mới
                      context.read<OrderHistoryController>().getOrderDetail(
                        widget.orderId,
                      );

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Đã gửi yêu cầu hủy đơn hàng thành công",
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  });
            },
            child: const Text("Xác nhận hủy"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Chi tiết đơn #${widget.orderId}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),

      body: Consumer<OrderHistoryController>(
        builder: (context, controller, child) {
          // 1. Loading
          if (controller.isLoadingDetail) {
            return const LoadingState(message: "Đang tải chi tiết đơn hàng...");
          }
          // 2. Error
          if (controller.currentDetail == null) {
            return ErrorState(
              message: controller.errorDetail.isNotEmpty
                  ? controller.errorDetail
                  : "Không thể tải thông tin đơn hàng",
              onRetry: () => controller.getOrderDetail(widget.orderId),
            );
          }

          final detail = controller.currentDetail!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Thông tin đơn hàng
                OrderDetailInfoCard(
                  title: "Thông tin đơn hàng",
                  items: [
                    {
                      "Ngày đặt": DateFormat(
                        'dd/MM/yyyy HH:mm',
                      ).format(detail.ngayTao),
                    },
                    {"Trạng thái": detail.trangThai},
                    {"Hình thức nhận": detail.hinhThucNhan},
                  ],
                ),
                const SizedBox(height: 15),

                // 2. Địa chỉ nhận hàng
                OrderDetailInfoCard(
                  title: "Địa chỉ nhận hàng",
                  items: [
                    {"Người nhận": detail.nguoiNhan},
                    {"Số điện thoại": detail.sdt},
                    {"Địa chỉ": detail.diaChiNhanHang},
                  ],
                ),
                const SizedBox(height: 20),

                // 3. Danh sách sản phẩm (Đã có logic click chuyển trang)
                OrderDetailProductList(
                  products: detail.chiTiet,
                  totalPrice: detail.tongTien,
                ),

                const SizedBox(
                  height: 80,
                ), // Padding bottom để tránh nút Hủy che nội dung
              ],
            ),
          );
        },
      ),

      // [PHẦN MỚI] BOTTOM BAR CHỨA NÚT HỦY
      bottomNavigationBar: Consumer<OrderHistoryController>(
        builder: (context, controller, child) {
          final detail = controller.currentDetail;
          if (detail == null) return const SizedBox.shrink();

          // 1. Kiểm tra trạng thái cho phép Hủy
          bool canCancel =
              detail.trangThai == "Chờ xử lý" ||
              detail.trangThai == "Chờ thanh toán" ||
              detail.trangThai == "Chờ duyệt";

          // 2. Kiểm tra trạng thái cho phép Xác nhận nhận hàng
          // [QUAN TRỌNG] Chuỗi "Đang giao" phải khớp chính xác với OrderConst trong C#
          bool canConfirm = detail.trangThai == "Đang giao";

          // Nếu không thuộc 2 trường hợp trên thì ẩn luôn
          if (!canCancel && !canConfirm) return const SizedBox.shrink();

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: canConfirm
                  // === CASE 1: NÚT XÁC NHẬN NHẬN HÀNG (Màu Xanh) ===
                  ? ElevatedButton(
                      onPressed: _onConfirmReceived,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.badgeNew, // Hoặc Colors.green
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Đã nhận được hàng",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    )
                  // === CASE 2: NÚT HỦY ĐƠN (Màu Đỏ - Code cũ của bạn) ===
                  : ElevatedButton(
                      onPressed: _onCancelOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Hủy đơn hàng",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
