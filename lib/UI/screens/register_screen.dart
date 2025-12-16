import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/UI/common/utils/color_opacity_ext.dart';
import 'package:nhathuoc_mobilee/UI/common/utils/dialog_helper.dart';
import 'package:nhathuoc_mobilee/controller/authcontroller.dart';
import 'package:nhathuoc_mobilee/UI/widgets/Register/register_form_card.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Đăng ký tài khoản",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(50),
              ),
            ),
          ),
          // Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Header
                const Text(
                  "Tạo tài khoản mới",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Điền thông tin để bắt đầu",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 32),
                // Form Card
                RegisterFormCard(
                  formKey: _formKey,
                  nameController: _nameController,
                  phoneController: _phoneController,
                  passController: _passController,
                  confirmPassController: _confirmPassController,
                  gender: _gender,
                  onGenderChanged: (value) => setState(() => _gender = value),
                  isObscurePass: _isObscurePass,
                  isObscureConfirm: _isObscureConfirm,
                  onToggleObscurePass: () =>
                      setState(() => _isObscurePass = !_isObscurePass),
                  onToggleObscureConfirm: () =>
                      setState(() => _isObscureConfirm = !_isObscureConfirm),
                  onRegister: _onRegisterPressed,
                  isLoading: _controller.isLoading,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
