import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/common/widget/address_selection_field.dart';
import 'package:nhathuoc_mobilee/common/widget/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:nhathuoc_mobilee/controller/ordercontroller.dart';
import 'package:nhathuoc_mobilee/models/useraddress.dart';
import 'package:nhathuoc_mobilee/common/utils/dialog_helper.dart';

class OrderAddressSection extends StatelessWidget {
  const OrderAddressSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderController>(
      builder: (context, controller, child) {
        // Nếu chọn "Nhận tại nhà thuốc" (value = 1) thì ẩn phần chọn địa chỉ
        if (controller.deliveryMethod == 1) return const SizedBox.shrink();

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.location_on,
                  color: AppColors.primaryPink,
                ),
                title: Text(
                  controller.selectedAddress?.fullAddress ?? "Chưa có địa chỉ",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: controller.selectedAddress != null
                    ? const Text(
                        "Địa chỉ nhận hàng",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      )
                    : null,
                trailing: const Icon(Icons.edit, color: AppColors.neutralGrey),
                onTap: () => _showAddressModal(context, controller),
              ),
              const Divider(height: 1, indent: 20, endIndent: 20),
              TextButton.icon(
                onPressed: () => _showAddressModal(context, controller),
                icon: const Icon(
                  Icons.add_location_alt_outlined,
                  color: Colors.blue,
                ),
                label: const Text(
                  "Chọn địa chỉ khác",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Hàm mở Modal danh sách địa chỉ
  void _showAddressModal(BuildContext context, OrderController c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddressModalContent(controller: c),
    );
  }
}

// --- Widget nội bộ: Nội dung Modal ---
class _AddressModalContent extends StatefulWidget {
  final OrderController controller;
  const _AddressModalContent({required this.controller});

  @override
  State<_AddressModalContent> createState() => _AddressModalContentState();
}

class _AddressModalContentState extends State<_AddressModalContent> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Danh sách địa chỉ",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Danh sách địa chỉ
          SizedBox(
            height: 250,
            child: widget.controller.addresses.isEmpty
                ? const Center(child: Text("Bạn chưa lưu địa chỉ nào"))
                : ListView.separated(
                    itemCount: widget.controller.addresses.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (ctx, index) {
                      final addr = widget.controller.addresses[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          addr.fullAddress,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        leading: Radio<UserAddress>(
                          value: addr,
                          groupValue: widget.controller.selectedAddress,
                          activeColor: AppColors.primaryPink,
                          onChanged: (val) {
                            widget.controller.setSelectedAddress(val!);
                            Navigator.pop(context); // Chọn xong đóng modal luôn
                          },
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => _deleteAddress(addr),
                        ),
                      );
                    },
                  ),
          ),

          const SizedBox(height: 10),

          // Nút Thêm Mới
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showAddNewAddressDialog,
              icon: const Icon(Icons.add),
              label: const Text("Thêm địa chỉ mới"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Logic Xóa Địa Chỉ
  void _deleteAddress(UserAddress addr) async {
    final confirm = await DialogHelper.showConfirmDialog(
      context,
      title: "Xóa địa chỉ",
      content: "Bạn có chắc muốn xóa địa chỉ này?",
      confirmText: "Xóa",
      confirmColor: Colors.red,
    );

    if (confirm == true) {
      await widget.controller.deleteAddress(
        addr,
        widget.controller.selectedAddress?.addressID.toString() ?? "",
      );
      setState(() {}); // Refresh list sau khi xóa
    }
  }

  // Logic Thêm Mới Địa Chỉ (Sử dụng Common Widgets)
  void _showAddNewAddressDialog() {
    final addressCtrl = TextEditingController();
    final detailCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Thêm địa chỉ mới",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Chọn Tỉnh/Huyện/Xã (Dùng Widget dùng chung siêu gọn)
              AddressSelectionField(
                controller: addressCtrl,
                labelText: "Tỉnh/Thành, Quận/Huyện...",
              ),

              const SizedBox(height: 15),

              // 2. Nhập số nhà/đường (Dùng CustomTextField)
              CustomTextField(
                controller: detailCtrl,
                labelText: "Số nhà, tên đường",
                prefixIcon: Icons.home_outlined,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "Hủy",
              style: TextStyle(color: AppColors.neutralGrey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              // Validate đơn giản
              if (addressCtrl.text.isEmpty || detailCtrl.text.isEmpty) {
                DialogHelper.showError(
                  context,
                  message: "Vui lòng nhập đầy đủ thông tin",
                );
                return;
              }

              // Xử lý chuỗi địa chỉ từ AddressSelectionField
              // Định dạng trả về mặc định: "Xã A, Huyện B, Tỉnh C"
              List<String> parts = addressCtrl.text.split(', ');
              String ward = parts.isNotEmpty ? parts[0] : "";
              String district = parts.length > 1 ? parts[1] : "";
              String province = parts.length > 2 ? parts[2] : "";

              // Gọi Controller thêm mới
              await widget.controller.addNewAddress(
                UserAddress(
                  addressID: 0,
                  province: province,
                  district: district,
                  ward: ward,
                  street: detailCtrl.text,
                  isDefault: true, // Mặc định chọn luôn địa chỉ mới thêm
                ),
                widget.controller.selectedAddress?.addressID.toString() ?? "",
              );

              Navigator.pop(ctx); // Đóng dialog thêm
              setState(() {}); // Refresh list bên ngoài
            },
            child: const Text("Lưu", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
