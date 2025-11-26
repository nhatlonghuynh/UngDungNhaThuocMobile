import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:nhathuoc_mobilee/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/controller/historyordercontroller.dart';
import 'package:nhathuoc_mobilee/widgets/HistoryOrder/order_detail_info_card.dart';
import 'package:nhathuoc_mobilee/widgets/HistoryOrder/order_detail_product_list.dart';

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
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          "Chi tiết đơn #${widget.orderId}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),

      // [PHẦN BODY GIỮ NGUYÊN NHƯ CŨ]
      body: Consumer<OrderHistoryController>(
        builder: (context, controller, child) {
          // 1. Loading
          if (controller.isLoadingDetail) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryPink),
            );
          }
          // 2. Error
          if (controller.currentDetail == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 50, color: Colors.red),
                  const SizedBox(height: 10),
                  Text(controller.errorDetail),
                  TextButton(
                    onPressed: () => controller.getOrderDetail(widget.orderId),
                    child: const Text("Thử lại"),
                  ),
                ],
              ),
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

          // Kiểm tra logic trạng thái cho phép hủy
          // Lưu ý: Chuỗi so sánh phải khớp chính xác với OrderConst trong C#
          bool canCancel =
              detail.trangThai == "Chờ xử lý" ||
              detail.trangThai == "Chờ thanh toán" ||
              detail.trangThai == "Chờ duyệt";

          if (!canCancel) return const SizedBox.shrink();

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
              child: ElevatedButton(
                onPressed: _onCancelOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Hủy đơn hàng",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
