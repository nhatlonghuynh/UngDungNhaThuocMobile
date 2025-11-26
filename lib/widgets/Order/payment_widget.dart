import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhathuoc_mobilee/models/giohang.dart';

final NumberFormat formatter = NumberFormat('#,###', 'vi_VN');

// 1. Widget chọn phương thức giao hàng
class DeliveryMethodSelector extends StatelessWidget {
  final int selectedMethod;
  final Function(int) onChanged;

  const DeliveryMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: RadioListTile<int>(
              value: 0,
              // ignore: deprecated_member_use
              groupValue: selectedMethod,
              // ignore: deprecated_member_use
              onChanged: (val) => onChanged(val!),
              title: const Text("Giao tận nơi", style: TextStyle(fontSize: 14)),
              activeColor: Colors.blue,
            ),
          ),
          Expanded(
            child: RadioListTile<int>(
              value: 1,
              // ignore: deprecated_member_use
              groupValue: selectedMethod,
              // ignore: deprecated_member_use
              onChanged: (val) => onChanged(val!),
              title: const Text(
                "Nhận tại nhà thuốc",
                style: TextStyle(fontSize: 14),
              ),
              activeColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}

// 2. Widget hiển thị địa chỉ
class AddressInfoSection extends StatelessWidget {
  final int deliveryMethod;
  final String address;
  final VoidCallback onSelectAddress;

  const AddressInfoSection({
    super.key,
    required this.deliveryMethod,
    required this.address,
    required this.onSelectAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(15),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Địa chỉ nhận hàng",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              if (deliveryMethod == 0)
                TextButton(
                  onPressed: onSelectAddress,
                  child: const Text("Thay đổi"),
                ),
            ],
          ),
          const SizedBox(height: 5),
          if (deliveryMethod == 0)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: Colors.blue, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    address == "Chưa chọn địa chỉ"
                        ? "Vui lòng chọn địa chỉ nhận hàng"
                        : "Nguyễn Văn A | 0909xxx\n$address",
                    style: TextStyle(
                      color: address == "Chưa chọn địa chỉ"
                          ? Colors.red
                          : Colors.black87,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.store, color: Colors.green, size: 24),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Nhà thuốc ABC - 123 Đường Láng, Hà Nội\n(Mở cửa: 8h00 - 22h00)",
                    style: TextStyle(height: 1.3),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// 3. Widget danh sách sản phẩm
class ProductListSection extends StatelessWidget {
  final List<GioHang> items;

  const ProductListSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Sản phẩm",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (ctx, i) => const Divider(),
            itemBuilder: (context, index) {
              final item = items[index];
              return Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.network(
                      item.anhURL,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: Colors.grey[200],
                        width: 60,
                        height: 60,
                        child: const Icon(Icons.image),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.tenThuoc,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "${formatter.format(item.donGia)}đ",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "x${item.soLuong} ${item.donVi}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${formatter.format(item.donGia * item.soLuong)}đ",
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// 4. Widget Tổng tiền
class PaymentSummarySection extends StatelessWidget {
  final double subTotal;
  final double shippingFee;
  final double discount;
  final double pointDiscount;
  final double finalTotal;
  final int earnedPoints;

  const PaymentSummarySection({
    super.key,
    required this.subTotal,
    required this.shippingFee,
    required this.discount,
    required this.pointDiscount,
    required this.finalTotal,
    required this.earnedPoints,
  });

  Widget _row(
    String label,
    double amount, {
    bool isNegative = false,
    bool isBold = false,
  }) {
    if (amount == 0 && label != "Tổng tiền hàng") {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            "${isNegative ? '-' : ''}${formatter.format(amount.abs())}đ",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isNegative ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          _row("Tổng tiền hàng", subTotal),
          _row("Voucher giảm giá", -discount, isNegative: true),
          _row("Đổi điểm thưởng", -pointDiscount, isNegative: true),
          _row("Phí vận chuyển", shippingFee),
          const Divider(height: 30, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Thành tiền",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "${formatter.format(finalTotal)}đ",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(5),
              // ignore: deprecated_member_use
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.monetization_on,
                  color: Colors.deepOrange,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  "Bạn sẽ nhận được +$earnedPoints điểm",
                  style: const TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
