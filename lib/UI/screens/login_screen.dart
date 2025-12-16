import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/UI/common/utils/color_opacity_ext.dart';
import 'package:nhathuoc_mobilee/UI/common/widget/custom_text_field.dart';
import 'package:nhathuoc_mobilee/UI/common/widget/primary_button.dart';
import 'package:provider/provider.dart';
import 'package:nhathuoc_mobilee/controller/authcontroller.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/UI/screens/forgotpassword_screen.dart';
import 'package:nhathuoc_mobilee/UI/screens/register_screen.dart';
import 'package:nhathuoc_mobilee/UI/common/utils/dialog_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();
  bool _isObscure = true; // Trạng thái ẩn hiện mật khẩu

  @override
  void dispose() {
    _phoneController.dispose();
    _passController.dispose();
    super.dispose();
  }

  // [Logic] Xử lý đăng nhập tách riêng
  void _handleLogin() async {
    FocusScope.of(context).unfocus();

    // 1. Validate cơ bản
    if (_phoneController.text.isEmpty || _passController.text.isEmpty) {
      // Dùng DialogHelper báo lỗi thay vì SnackBar thường cho chuyên nghiệp
      DialogHelper.showError(
        context,
        message: "Vui lòng nhập đầy đủ thông tin",
      );
      return;
    }

    // 2. Gọi Controller
    final authController = context.read<AuthController>();
    final result = await authController.handleLogin(
      _phoneController.text,
      _passController.text,
    );

    if (!mounted) return;

    // 3. Xử lý kết quả
    if (result['success']) {
      Navigator.pop(context, true); // Trả về kết quả thành công
    } else {
      // Báo lỗi từ Server
      DialogHelper.showError(context, message: result['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe loading từ Controller
    final isLoading = context.select<AuthController, bool>((c) => c.isLoading);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Background trang trí
          Container(
            height: 320,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(60)),
            ),
          ),

          // 2. Nội dung chính
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Logo
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Image.network(
                      'https://www.flaticon.com/free-icon/pills_4418031?term=medicine&page=1&position=23&origin=search&related_id=4418031',
                      height: 70,
                      color: AppColors.primary,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.local_pharmacy,
                        size: 70,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    "Chào mừng trở lại!",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Đăng nhập để tiếp tục mua sắm",
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),

                  const SizedBox(height: 40),

                  // 3. Card Form
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // [DRY] Dùng CustomTextField cho Số điện thoại
                        CustomTextField(
                          controller: _phoneController,
                          labelText: "Số điện thoại",
                          prefixIcon: Icons.phone_android,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 20),

                        // [DRY] Dùng CustomTextField cho Mật khẩu
                        CustomTextField(
                          controller: _passController,
                          labelText: "Mật khẩu",
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          isObscure: _isObscure,
                          onToggleObscure: () =>
                              setState(() => _isObscure = !_isObscure),
                          textInputAction: TextInputAction.done,
                        ),

                        // Quên mật khẩu
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen(),
                              ),
                            ),
                            child: const Text(
                              "Quên mật khẩu?",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // [DRY] Dùng PrimaryButton
                        PrimaryButton(
                          text: "Đăng nhập",
                          isLoading: isLoading,
                          onPressed: _handleLogin,
                          backgroundColor: AppColors
                              .secondary, // Override màu cam cho nút Đăng nhập
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Chưa có tài khoản? ",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        ),
                        child: const Text(
                          "Đăng ký ngay",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 8.0),
                child: Material(
                  color: Colors
                      .transparent, // Để hiệu ứng gợn sóng (ripple) hiển thị đẹp
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    // Chỉ pop nếu có thể (an toàn hơn pop())
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        // SỬA: Dùng .withOpacity thay vì .withOpacity
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
