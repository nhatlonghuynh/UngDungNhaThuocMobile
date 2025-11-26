import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';
import 'package:provider/provider.dart';
import 'package:nhathuoc_mobilee/controller/ordercontroller.dart';

class OrderPaymentSection extends StatelessWidget {
  const OrderPaymentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderController>(
      builder: (context, c, child) {
        return Column(
          children: [
            // 1. Vận chuyển
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Hình thức nhận hàng",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  RadioListTile(
                    title: const Text("Giao tận nơi"),
                    value: 0,
                    groupValue: c.deliveryMethod,
                    activeColor: AppColors.primaryPink,
                    onChanged: (v) => c.setDeliveryMethod(v!),
                  ),
                  RadioListTile(
                    title: const Text("Nhận tại nhà thuốc"),
                    value: 1,
                    groupValue: c.deliveryMethod,
                    activeColor: AppColors.primaryPink,
                    onChanged: (v) => c.setDeliveryMethod(v!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 2. Thanh toán
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Phương thức thanh toán",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  RadioListTile(
                    title: const Text("Thanh toán khi nhận hàng (COD)"),
                    value: "COD",
                    groupValue: c.paymentMethod,
                    activeColor: AppColors.primaryPink,
                    onChanged: (v) => c.setPaymentMethod(v!),
                  ),
                  RadioListTile(
                    title: const Text("Thanh toán PayOS (QR Code)"),
                    value: "PAYOS",
                    groupValue: c.paymentMethod,
                    activeColor: AppColors.primaryPink,
                    onChanged: (v) => c.setPaymentMethod(v!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 3. Ghi chú
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(15),
              child: TextField(
                onChanged: c.setNote,
                decoration: InputDecoration(
                  labelText: "Lưu ý cho người bán",
                  prefixIcon: const Icon(
                    Icons.note_alt_outlined,
                    color: AppColors.neutralGrey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 4. Điểm tích lũy
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      "Dùng điểm (${c.maxPoints})",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text("1 điểm = 10đ"),
                    value: c.usePoints,
                    activeColor: AppColors.primaryPink,
                    onChanged: c.maxPoints > 0 ? c.toggleUsePoints : null,
                  ),
                  if (c.usePoints)
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Nhập số điểm muốn dùng",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (val) =>
                          c.setPointsToUse(int.tryParse(val) ?? 0),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
