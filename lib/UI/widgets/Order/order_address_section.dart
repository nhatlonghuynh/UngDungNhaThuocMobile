import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/UI/common/widget/address_selection_field.dart';
import 'package:nhathuoc_mobilee/UI/common/widget/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:nhathuoc_mobilee/controller/ordercontroller.dart';
import 'package:nhathuoc_mobilee/models/diachikhachhang.dart';
import 'package:nhathuoc_mobilee/UI/common/utils/dialog_helper.dart';
import 'package:nhathuoc_mobilee/manager/usermanager.dart';

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
                trailing: const Icon(
                  Icons.edit,
                  color: AppColors.textSecondary,
                ),
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
              AddressSelectionField(
                controller: addressCtrl,
                labelText: "Tỉnh/Thành, Quận/Huyện, Phường/Xã",
              ),
              const SizedBox(height: 15),
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
                // --- XỬ LÝ TÁCH CHUỖI AN TOÀN (Tránh Crash) ---
                List<String> parts = addressCtrl.text.split(', ');
                String province = "";
                String district = "";
                String ward = "";

                // Xử lý ngược từ cuối lên để đảm bảo lấy đúng Tỉnh/Thành phố
                if (parts.isNotEmpty) {
                  province = parts.last; // Phần tử cuối cùng luôn là Tỉnh/TP
                  if (parts.length >= 2) district = parts[parts.length - 2];
                  if (parts.length >= 3) {
                    // Gộp các phần còn lại làm Xã/Phường (đề phòng địa chỉ dài)
                    ward = parts.sublist(0, parts.length - 2).join(', ');
                  }
                }

                String currentUserId = UserManager().userId;

                // Gọi Controller để thêm mới
                await widget.controller.addNewAddress(
                  UserAddress(
                    addressID: 0,
                    province: province,
                    district: district,
                    ward: ward,
                    street: detailCtrl.text,
                    isDefault: true, // Mặc định chọn luôn cái mới thêm
                  ),
                  currentUserId,
                );

                // Đóng Dialog nhập liệu
                if (ctx.mounted) Navigator.pop(ctx);
                // Đóng Modal chọn địa chỉ (để user thấy địa chỉ mới đã được chọn ở màn hình chính)
                if (context.mounted) Navigator.pop(context);
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
