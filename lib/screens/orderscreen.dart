import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/common/widget/primary_button.dart';
import 'package:nhathuoc_mobilee/screens/payos_payment_screen.dart';
import 'package:provider/provider.dart';
import 'package:nhathuoc_mobilee/controller/ordercontroller.dart';
import 'package:nhathuoc_mobilee/models/giohang.dart';
import 'package:nhathuoc_mobilee/common/utils/dialog_helper.dart';
import 'package:nhathuoc_mobilee/widgets/order/order_address_section.dart';
import 'package:nhathuoc_mobilee/widgets/order/order_payment_section.dart';
import 'package:nhathuoc_mobilee/widgets/order/order_summary_section.dart';

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
        appBar: AppBar(
          title: const Text(
            "Xác nhận đơn hàng",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
        ),
        backgroundColor: AppColors.scaffoldBackground,

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
          builder: (context, controller, _) => Container(
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
            ),
            child: SafeArea(
              child: PrimaryButton(
                text: "ĐẶT HÀNG",
                isLoading: controller.isOrdering,
                onPressed: () => _handlePlaceOrder(context, controller),
              ),
            ),
          ),
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
            builder: (_) => PayOSPaymentScreen(
              paymentUrl: result["CheckoutUrl"],
              returnUrlScheme: "nhathuoc://payment-result",
            ),
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
      if (context.mounted) DialogHelper.showError(context, message: "Lỗi: $e");
    }
  }

  // Dialog thành công (Dùng DialogHelper hoặc custom đẹp hơn)
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
          "Cảm ơn bạn đã mua sắm tại Nhà thuốc HUIT.",
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPink,
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
