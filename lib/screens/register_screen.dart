import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/common/widget/custom_text_field.dart';
import 'package:nhathuoc_mobilee/common/widget/primary_button.dart';
import 'package:nhathuoc_mobilee/controller/authcontroller.dart';
import 'package:nhathuoc_mobilee/common/utils/dialog_helper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthController _controller = AuthController();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();

  // Trạng thái
  String _gender = "Nam";
  bool _isObscurePass = true;
  bool _isObscureConfirm = true;

  @override
  void initState() {
    super.initState();
    // Lắng nghe thay đổi từ controller để rebuild UI (cho nút loading)
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  // Logic xử lý Đăng ký
  // Logic xử lý Đăng ký
  void _onRegisterPressed() async {
    if (!_formKey.currentState!.validate()) return;

    // Gọi API
    final result = await _controller.handleRegister(
      name: _nameController.text,
      phone: _phoneController.text,
      pass: _passController.text,
      confirmPass: _confirmPassController.text,
      gender: _gender,
      address: 'Địa chỉ không cố định',
    );

    if (!mounted) return;

    // Xử lý kết quả
    if (result['success']) {
      // [DRY] Sử dụng DialogHelper chuẩn
      DialogHelper.showSuccessDialog(
        context,
        title: "Đăng ký thành công",
        message: "Tài khoản đã được tạo.\nVui lòng đăng nhập để tiếp tục.",
        onPressed: () {
          Navigator.pop(context); // Quay về màn hình Login
        },
      );
    } else {
      // Báo lỗi
      DialogHelper.showError(
        context,
        message: result['message'] ?? "Có lỗi xảy ra",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Đăng ký tài khoản",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                "Tạo tài khoản mới",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPink,
                ),
              ),
              const SizedBox(height: 20),

              // 1. Họ tên
              CustomTextField(
                controller: _nameController,
                labelText: "Họ và tên",
                prefixIcon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                validator: (value) => (value == null || value.isEmpty)
                    ? "Vui lòng nhập họ tên"
                    : null,
              ),
              const SizedBox(height: 15),

              // 2. Số điện thoại
              CustomTextField(
                controller: _phoneController,
                labelText: "Số điện thoại",
                prefixIcon: Icons.phone_android,
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
              const SizedBox(height: 15),

              // 3. Giới tính (Custom UI riêng vì CustomTextField không hỗ trợ Radio)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "Giới tính",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textBrown,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      _buildRadioOption("Nam"),
                      _buildRadioOption("Nữ"),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // 4. Mật khẩu
              CustomTextField(
                controller: _passController,
                labelText: "Mật khẩu",
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                isObscure: _isObscurePass,
                onToggleObscure: () =>
                    setState(() => _isObscurePass = !_isObscurePass),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập mật khẩu";
                  }
                  if (value.length < 6) return "Mật khẩu ít nhất 6 ký tự";
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // 5. Xác nhận mật khẩu
              CustomTextField(
                controller: _confirmPassController,
                labelText: "Xác nhận mật khẩu",
                prefixIcon: Icons.check_circle_outline,
                isPassword: true,
                isObscure: _isObscureConfirm,
                onToggleObscure: () =>
                    setState(() => _isObscureConfirm = !_isObscureConfirm),
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập xác nhận mật khẩu";
                  }
                  if (value != _passController.text) {
                    return "Mật khẩu không khớp";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // 6. Nút Đăng ký (Dùng PrimaryButton)
              PrimaryButton(
                text: "ĐĂNG KÝ",
                isLoading: _controller.isLoading,
                onPressed: _onRegisterPressed,
                backgroundColor: Colors.green[600], // Override màu xanh lá
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget nhỏ cho Radio button (chỉ dùng nội bộ file này)
  Widget _buildRadioOption(String value) {
    return Expanded(
      child: RadioListTile(
        title: Text(value),
        value: value,
        groupValue: _gender,
        activeColor: AppColors.primaryPink,
        contentPadding: EdgeInsets.zero,
        onChanged: (v) => setState(() => _gender = v!),
      ),
    );
  }
}
