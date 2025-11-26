import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/UI/common/widget/address_picker_dialog.dart';
import 'package:nhathuoc_mobilee/UI/common/widget/custom_text_field.dart';

class AddressSelectionField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;

  const AddressSelectionField({
    super.key,
    required this.controller,
    this.labelText = "Tỉnh/Thành phố, Quận/Huyện...",
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Tự động gọi Dialog chọn địa chỉ
        final result = await showDialog<String>(
          context: context,
          builder: (_) => const AddressPickerDialog(),
        );

        // Nếu có kết quả trả về thì điền vào controller
        if (result != null) {
          controller.text = result;
        }
      },
      child: AbsorbPointer(
        // Chặn bàn phím hiện lên
        child: CustomTextField(
          controller: controller,
          labelText: labelText,
          prefixIcon: Icons.location_city,
          // Có thể thêm icon mũi tên xuống để người dùng biết là menu chọn
          // (Cần sửa nhẹ CustomTextField để hỗ trợ suffixIcon tùy chỉnh nếu muốn,
          // nhưng hiện tại để mặc định cũng ok)
          validator: validator,
        ),
      ),
    );
  }
}
