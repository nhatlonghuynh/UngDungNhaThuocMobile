import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/controller/password_recovery_controller.dart';
import 'package:nhathuoc_mobilee/UI/screens/resetpassword_screen.dart';
import 'package:provider/provider.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/UI/common/widget/custom_text_field.dart';
import 'package:nhathuoc_mobilee/UI/common/widget/primary_button.dart';
import 'package:nhathuoc_mobilee/UI/common/widget/glass_card.dart';

import '../common/utils/dialog_helper.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PasswordRecoveryController(),
      child: const ForgotPasswordView(),
    );
  }
}

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PasswordRecoveryController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Quên mật khẩu",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
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
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Header
                const Text(
                  "Khôi phục mật khẩu",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Nhập tên đăng nhập hoặc số điện thoại",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 32),
                // Form Card
                GlassCard(
                  padding: const EdgeInsets.all(28),
                  borderRadius: 28,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _usernameController,
                        labelText: "Tên đăng nhập / Số điện thoại",
                        prefixIcon: Icons.person_outline_rounded,
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        text: "TIẾP TỤC",
                        isLoading: controller.isLoading,
                        onPressed: () async {
                          if (_usernameController.text.isEmpty) {
                            DialogHelper.showError(
                              context,
                              message: "Vui lòng nhập thông tin",
                            );
                            return;
                          }

                          final result = await context
                              .read<PasswordRecoveryController>()
                              .requestToken(_usernameController.text);

                          if (!context.mounted) return;
                          if (result['success']) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ResetPasswordScreen(
                                  username: _usernameController.text,
                                  token: result['resetToken'],
                                ),
                              ),
                            );
                          } else {
                            DialogHelper.showError(
                              context,
                              message: result['message'] ?? "Có lỗi xảy ra",
                            );
                          }
                        },
                        backgroundColor: AppColors.primary,
                      ),
                    ],
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
