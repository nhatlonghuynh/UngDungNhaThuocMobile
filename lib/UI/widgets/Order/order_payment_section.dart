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
            _buildSection(
              title: "Hình thức nhận hàng",
              children: [
                RadioListTile(
                  title: const Text("Giao tận nơi"),
                  value: 0,
                  groupValue: c.deliveryMethod,
                  activeColor: AppColors.primary,
                  onChanged: (v) => c.setDeliveryMethod(v!),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
                RadioListTile(
                  title: const Text("Nhận tại nhà thuốc"),
                  value: 1,
                  groupValue: c.deliveryMethod,
                  activeColor: AppColors.primary,
                  onChanged: (v) => c.setDeliveryMethod(v!),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 2. Thanh toán
            _buildSection(
              title: "Phương thức thanh toán",
              children: [
                RadioListTile(
                  title: const Text("Thanh toán khi nhận hàng (COD)"),
                  value: "COD",
                  groupValue: c.paymentMethod,
                  activeColor: AppColors.primary,
                  onChanged: (v) => c.setPaymentMethod(v!),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
                RadioListTile(
                  title: const Text("Thanh toán PayOS (QR Code)"),
                  value: "PAYOS",
                  groupValue: c.paymentMethod,
                  activeColor: AppColors.primary,
                  onChanged: (v) => c.setPaymentMethod(v!),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ],
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
                    color: AppColors.textSecondary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  isDense: true,
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
                    subtitle: const Text(
                      "1 điểm = 10đ",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    value: c.usePoints,
                    activeColor: AppColors.primary,
                    // Disable switch nếu không có điểm
                    onChanged: c.maxPoints > 0 ? c.toggleUsePoints : null,
                    contentPadding: EdgeInsets.zero,
                  ),

                  // Chỉ hiện ô nhập khi bật Switch
                  if (c.usePoints)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Nhập số điểm (Tối đa ${c.maxPoints})",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixText: "điểm",
                          isDense: true,
                        ),
                        onChanged: (val) => c.setPointsToUse(val),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper widget để code gọn hơn
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          ...children,
        ],
      ),
    );
  }
}
