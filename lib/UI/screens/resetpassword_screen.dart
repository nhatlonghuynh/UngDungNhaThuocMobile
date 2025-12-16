import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/UI/common/utils/color_opacity_ext.dart';
import 'package:nhathuoc_mobilee/UI/common/utils/dialog_helper.dart';
import 'package:nhathuoc_mobilee/UI/common/widget/custom_text_field.dart';
import 'package:nhathuoc_mobilee/UI/common/widget/primary_button.dart';
import 'package:provider/provider.dart';
import 'package:nhathuoc_mobilee/controller/password_recovery_controller.dart';
import 'package:nhathuoc_mobilee/UI/common/widget/glass_card.dart';

class ResetPasswordScreen extends StatelessWidget {
  final String username;
  final String token;

  const ResetPasswordScreen({
    super.key,
    required this.username,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PasswordRecoveryController(),
      child: ResetPasswordView(username: username, token: token),
    );
  }
}

class ResetPasswordView extends StatefulWidget {
  final String username;
  final String token;

  const ResetPasswordView({
    super.key,
    required this.username,
    required this.token,
  });

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  // Trạng thái ẩn hiện mật khẩu
  bool _isObscureNew = true;
  bool _isObscureConfirm = true;

  @override
  void dispose() {
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  // Logic xử lý đổi mật khẩu
  void _handleSubmit(PasswordRecoveryController controller) async {
    if (!_formKey.currentState!.validate()) return;

    // Ẩn bàn phím
    FocusScope.of(context).unfocus();

    final result = await controller.submitReset(
      username: widget.username,
      token: widget.token,
      newPass: _newPassCtrl.text,
    );

    if (!mounted) return;

    if (result['success']) {
      // [DRY] Dùng Dialog thông báo thành công rồi tự động quay về trang Login
      await DialogHelper.showConfirmDialog(
        context,
        title: "Thành công",
        content: "Đổi mật khẩu thành công! Vui lòng đăng nhập lại.",
        confirmText: "Về trang chủ",
        cancelText: "", // Ẩn nút hủy (Bắt buộc bấm OK)
      );

      if (mounted) {
        // Pop hết các màn hình cũ để về lại Login (hoặc màn hình đầu tiên)
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } else {
      // [DRY] Dùng Dialog báo lỗi
      DialogHelper.showError(
        context,
        message: result['message'] ?? "Có lỗi xảy ra",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PasswordRecoveryController>();

    return Scaffold(
      backgroundColor: AppColors.background, // Màu nền chuẩn
      appBar: AppBar(
        title: const Text(
          "Đặt lại mật khẩu",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary, // Màu chủ đạo
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
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
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Header
                const Text(
                  "Đặt lại mật khẩu",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Vui lòng nhập mật khẩu mới cho tài khoản",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 32),
                // Form Card
                Form(
                  key: _formKey,
                  child: GlassCard(
                    padding: const EdgeInsets.all(28),
                    borderRadius: 28,
                    child: Column(
                      children: [
                        // 1. Mật khẩu mới
                        CustomTextField(
                          controller: _newPassCtrl,
                          labelText: "Mật khẩu mới",
                          prefixIcon: Icons.lock_outline_rounded,
                          isPassword: true,
                          isObscure: _isObscureNew,
                          onToggleObscure: () =>
                              setState(() => _isObscureNew = !_isObscureNew),
                          validator: (v) => (v!.length < 6)
                              ? "Mật khẩu phải từ 6 ký tự"
                              : null,
                        ),
                        const SizedBox(height: 20),
                        // 2. Xác nhận mật khẩu
                        CustomTextField(
                          controller: _confirmPassCtrl,
                          labelText: "Xác nhận mật khẩu",
                          prefixIcon: Icons.lock_reset_outlined,
                          isPassword: true,
                          isObscure: _isObscureConfirm,
                          onToggleObscure: () => setState(
                            () => _isObscureConfirm = !_isObscureConfirm,
                          ),
                          textInputAction: TextInputAction.done,
                          validator: (v) => (v != _newPassCtrl.text)
                              ? "Mật khẩu không khớp"
                              : null,
                        ),
                        const SizedBox(height: 24),
                        // 3. Nút Xác nhận
                        PrimaryButton(
                          text: "XÁC NHẬN",
                          isLoading: controller.isLoading,
                          onPressed: () => _handleSubmit(controller),
                        ),
                      ],
                    ),
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
