import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/UI/common/utils/dialog_helper.dart';
import 'package:nhathuoc_mobilee/UI/common/widget/primary_button.dart';
import 'package:nhathuoc_mobilee/UI/screens/payos_payment_screen.dart';
import 'package:provider/provider.dart';
import 'package:nhathuoc_mobilee/controller/ordercontroller.dart';
import 'package:nhathuoc_mobilee/models/giohang.dart';
import 'package:nhathuoc_mobilee/UI/widgets/Order/order_address_section.dart';
import 'package:nhathuoc_mobilee/UI/widgets/Order/order_payment_section.dart';
import 'package:nhathuoc_mobilee/UI/widgets/Order/order_summary_section.dart';

class OrderScreen extends StatelessWidget {
  final List<GioHang> selectedItems;
  final String userId;

  const OrderScreen({
    super.key,
    required this.selectedItems,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrderController()..loadUserAddresses(userId: userId),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            "Xác nhận đơn hàng",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),

        // Dùng Consumer ở cấp cao nhất để lấy controller
        body: Consumer<OrderController>(
          builder: (context, controller, child) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  // 1. Địa chỉ
                  const OrderAddressSection(),
                  const SizedBox(height: 10),

                  // 2. Thanh toán & Vận chuyển & Ghi chú & Điểm
                  const OrderPaymentSection(),
                  const SizedBox(height: 10),

                  // 3. Tổng tiền
                  OrderSummarySection(
                    controller: controller,
                    selectedItems: selectedItems,
                  ),

                  const SizedBox(
                    height: 100,
                  ), // Padding bottom cho nút đặt hàng
                ],
              ),
            );
          },
        ),

        // Bottom Bar (Nút Đặt hàng)
        bottomNavigationBar: Consumer<OrderController>(
          builder: (context, controller, _) {
            // Logic check xem có đang đồng bộ địa chỉ không
            // (selectedAddress != null và ID <= 0 nghĩa là đang chờ server trả ID thật)
            bool isSyncingAddress =
                controller.deliveryMethod == 0 &&
                controller.selectedAddress != null &&
                controller.selectedAddress!.addressID <= 0;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: PrimaryButton(
                  // Nếu đang sync thì hiện text khác cho user hiểu
                  text: isSyncingAddress ? "ĐANG LƯU ĐỊA CHỈ..." : "ĐẶT HÀNG",

                  // Nút loading khi đang gọi API đặt hàng
                  isLoading: controller.isOrdering,

                  // Disable nút nếu đang sync địa chỉ
                  onPressed: isSyncingAddress
                      ? null
                      : () => _handlePlaceOrder(context, controller),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Logic xử lý đặt hàng (PayOS hoặc COD)
  void _handlePlaceOrder(BuildContext context, OrderController c) async {
    try {
      // Gọi API tạo đơn
      final result = await c.placeOrder(selectedItems);

      // Trường hợp 1: COD hoặc Lỗi Link
      if (c.paymentMethod == "COD" || result["CheckoutUrl"] == null) {
        await c.clearCart(selectedItems);
        if (context.mounted) _showSuccessDialog(context);
        return;
      }

      // Trường hợp 2: PayOS
      if (context.mounted) {
        final payResult = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                PayOSPaymentScreen(paymentUrl: result["CheckoutUrl"]),
          ),
        );

        if (payResult["success"] == true) {
          await c.confirmPayOS(result["MaHD"], result["payOSOrderCode"]);
          await c.clearCart(selectedItems);
          if (context.mounted) _showSuccessDialog(context);
        } else {
          if (context.mounted) {
            DialogHelper.showError(
              context,
              message: "Thanh toán bị hủy hoặc thất bại",
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        String errorMsg = e.toString().replaceAll("Exception:", "").trim();
        DialogHelper.showError(context, message: errorMsg);
      }
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        title: const Text(
          "Đặt hàng thành công!",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Cảm ơn bạn đã mua sắm tại Nhà thuốc",
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              ),
              child: const Text(
                "Về trang chủ",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
