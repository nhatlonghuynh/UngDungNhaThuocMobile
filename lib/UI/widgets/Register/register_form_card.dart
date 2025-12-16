import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/UI/common/utils/color_opacity_ext.dart';
import 'package:nhathuoc_mobilee/UI/common/widget/custom_text_field.dart';
import 'package:nhathuoc_mobilee/UI/common/widget/primary_button.dart';
import 'package:nhathuoc_mobilee/UI/common/widget/glass_card.dart';

/// Form card của màn hình Register
class RegisterFormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController passController;
  final TextEditingController confirmPassController;
  final String gender;
  final Function(String) onGenderChanged;
  final bool isObscurePass;
  final bool isObscureConfirm;
  final VoidCallback onToggleObscurePass;
  final VoidCallback onToggleObscureConfirm;
  final VoidCallback onRegister;
  final bool isLoading;

  const RegisterFormCard({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.phoneController,
    required this.passController,
    required this.confirmPassController,
    required this.gender,
    required this.onGenderChanged,
    required this.isObscurePass,
    required this.isObscureConfirm,
    required this.onToggleObscurePass,
    required this.onToggleObscureConfirm,
    required this.onRegister,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(28),
      borderRadius: 28,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: nameController,
              labelText: "Họ và tên",
              prefixIcon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
              validator: (value) => (value == null || value.isEmpty)
                  ? "Vui lòng nhập họ tên"
                  : null,
            ),
            const SizedBox(height: 18),
            CustomTextField(
              controller: phoneController,
              labelText: "Số điện thoại",
              prefixIcon: Icons.phone_android_rounded,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Vui lòng nhập số điện thoại";
                }
                if (!RegExp(r'^\d{9,11}$').hasMatch(value)) {
                  return "Số điện thoại không hợp lệ";
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            _buildGenderSelector(),
            const SizedBox(height: 18),
            CustomTextField(
              controller: passController,
              labelText: "Mật khẩu",
              prefixIcon: Icons.lock_outline_rounded,
              isPassword: true,
              isObscure: isObscurePass,
              onToggleObscure: onToggleObscurePass,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Vui lòng nhập mật khẩu";
                }
                if (value.length < 6) return "Mật khẩu ít nhất 6 ký tự";
                return null;
              },
            ),
            const SizedBox(height: 18),
            CustomTextField(
              controller: confirmPassController,
              labelText: "Xác nhận mật khẩu",
              prefixIcon: Icons.check_circle_outline_rounded,
              isPassword: true,
              isObscure: isObscureConfirm,
              onToggleObscure: onToggleObscureConfirm,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Vui lòng nhập xác nhận mật khẩu";
                }
                if (value != passController.text) {
                  return "Mật khẩu không khớp";
                }
                return null;
              },
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              text: "ĐĂNG KÝ",
              isLoading: isLoading,
              onPressed: onRegister,
              backgroundColor: AppColors.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "Giới tính",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(child: _buildGenderOption("Nam", Icons.male_rounded)),
            const SizedBox(width: 12),
            Expanded(child: _buildGenderOption("Nữ", Icons.female_rounded)),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String value, IconData icon) {
    final isSelected = gender == value;
    return InkWell(
      onTap: () => onGenderChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.border.withOpacity(0.6),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
