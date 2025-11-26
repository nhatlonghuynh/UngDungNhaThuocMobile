import 'package:flutter/material.dart';
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
      backgroundColor: AppColors.scaffoldBackground,
      body: Stack(
        children: [
          // 1. Background trang trí
          Container(
            height: 320,
            decoration: const BoxDecoration(
              color: AppColors.primaryPink,
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
                      'https://cdn-icons-png.flaticon.com/512/3063/3063822.png',
                      height: 70,
                      color: AppColors.primaryPink,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.local_pharmacy,
                        size: 70,
                        color: AppColors.primaryPink,
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textBrown.withOpacity(0.1),
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
                                color: AppColors.primaryPink,
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
                              .secondaryGreen, // Override màu xanh cho nút Đăng nhập
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
                          color: AppColors.textBrown,
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
                            color: AppColors.primaryPink,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primaryPink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
