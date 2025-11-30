import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/UI/common/widget/address_selection_field.dart';
import 'package:nhathuoc_mobilee/UI/common/widget/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:nhathuoc_mobilee/controller/ordercontroller.dart';
import 'package:nhathuoc_mobilee/models/diachikhachhang.dart'; // Import đúng file model của bạn
import 'package:nhathuoc_mobilee/UI/common/utils/dialog_helper.dart';
import 'package:nhathuoc_mobilee/manager/usermanager.dart'; // [MỚI] Import để lấy UserId

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
                  color: AppColors.primary,
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
                trailing: const Icon(Icons.edit, color: AppColors.textSecondary),
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
                          activeColor: AppColors.primary,
                          onChanged: (val) {
                            widget.controller.setSelectedAddress(val!);
                            Navigator.pop(context);
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

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showAddNewAddressDialog,
              icon: const Icon(Icons.add),
              label: const Text("Thêm địa chỉ mới"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
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

  void _deleteAddress(UserAddress addr) async {
    final confirm = await DialogHelper.showConfirmDialog(
      context,
      title: "Xóa địa chỉ",
      content: "Bạn có chắc muốn xóa địa chỉ này?",
      confirmText: "Xóa",
      confirmColor: Colors.red,
    );

    if (confirm == true) {
      // SỬA: Lấy UserId từ UserManager
      await widget.controller.deleteAddress(addr, UserManager().userId);
      if (mounted) setState(() {});
    }
  }

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
              // Chọn Tỉnh/Huyện/Xã
              AddressSelectionField(
                controller: addressCtrl,
                labelText: "Tỉnh/Thành, Quận/Huyện...",
              ),
              const SizedBox(height: 15),
              // Nhập đường
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
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              if (addressCtrl.text.isEmpty || detailCtrl.text.isEmpty) {
                DialogHelper.showError(
                  context,
                  message: "Vui lòng nhập đầy đủ thông tin",
                );
                return;
              }
              try {
                // Parse địa chỉ
                List<String> parts = addressCtrl.text.split(', ');
                String ward = parts.isNotEmpty ? parts[0] : "";
                String district = parts.length > 1 ? parts[1] : "";
                String province = parts.length > 2 ? parts[2] : "";

                // [SỬA QUAN TRỌNG] Lấy UserId chuẩn
                String currentUserId = UserManager().userId;

                await widget.controller.addNewAddress(
                  UserAddress(
                    tempId:
                        'abc', // <-- BỎ DÒNG NÀY nếu Model của bạn không có field tempId
                    addressID: 0, // ID tạm = 0, Service sẽ trả về ID thật
                    province: province,
                    district: district,
                    ward: ward,
                    street: detailCtrl.text,
                    isDefault: true,
                  ),
                  currentUserId, // <-- Truyền đúng UserId vào đây
                );

                Navigator.pop(ctx);
                Navigator.pop(context);
              } catch (e) {
                DialogHelper.showError(context, message: e.toString());
              }
            },
            child: const Text("Lưu", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
