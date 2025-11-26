import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/common/widget/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:nhathuoc_mobilee/common/constants/appcolor.dart'; 
import 'package:nhathuoc_mobilee/controller/usercontroller.dart';
import 'package:nhathuoc_mobilee/common/utils/dialog_helper.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileController(),
      child: const ChangePasswordView(),
    );
  }
}

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  
  // Trạng thái ẩn/hiện mật khẩu
  bool _obsOld = true;
  bool _obsNew = true;
  bool _obsConfirm = true;

  @override
  void dispose() {
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  // Logic xử lý đổi mật khẩu (Tách ra cho gọn)
  void _handleChangePass(ProfileController controller) async {
    // 1. Validate Form
    if (!_formKey.currentState!.validate()) return;

    // Ẩn bàn phím
    FocusScope.of(context).unfocus();

    // 2. [DRY] Dialog Xác nhận (Dùng chung)
    final confirm = await DialogHelper.showConfirmDialog(
      context,
      title: "Xác nhận",
      content: "Bạn có chắc chắn muốn đổi mật khẩu không?",
      confirmText: "Đổi ngay",
    );

    if (confirm != true) return;

    // 3. Gọi API
    final result = await controller.changePass(_oldPassCtrl.text, _newPassCtrl.text);

    if (!mounted) return;

    // 4. Xử lý kết quả
    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đổi mật khẩu thành công!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Có lỗi xảy ra'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProfileController>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text("Đổi mật khẩu", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryPink,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 1. Mật khẩu cũ (Dùng CustomTextField với isPassword = true)
              CustomTextField(
                controller: _oldPassCtrl,
                labelText: "Mật khẩu cũ",
                prefixIcon: Icons.lock_outline,
                isPassword: true, 
                isObscure: _obsOld,
                onToggleObscure: () => setState(() => _obsOld = !_obsOld),
                validator: (val) => val!.isEmpty ? "Vui lòng nhập mật khẩu cũ" : null,
              ),
              const SizedBox(height: 20),

              // 2. Mật khẩu mới
              CustomTextField(
                controller: _newPassCtrl,
                labelText: "Mật khẩu mới",
                prefixIcon: Icons.vpn_key_outlined,
                isPassword: true,
                isObscure: _obsNew,
                onToggleObscure: () => setState(() => _obsNew = !_obsNew),
                validator: (val) {
                  if (val!.isEmpty) return "Nhập mật khẩu mới";
                  if (val.length < 6) return "Mật khẩu phải từ 6 ký tự";
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 3. Xác nhận mật khẩu
              CustomTextField(
                controller: _confirmPassCtrl,
                labelText: "Xác nhận mật khẩu",
                prefixIcon: Icons.check_circle_outline,
                isPassword: true,
                isObscure: _obsConfirm,
                onToggleObscure: () => setState(() => _obsConfirm = !_obsConfirm),
                textInputAction: TextInputAction.done,
                validator: (val) {
                  if (val!.isEmpty) return "Nhập lại mật khẩu mới";
                  if (val != _newPassCtrl.text) return "Mật khẩu không khớp";
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // 4. Nút Lưu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading ? null : () => _handleChangePass(controller),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                    shadowColor: AppColors.primaryPink.withOpacity(0.4),
                  ),
                  child: controller.isLoading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          "LƯU THAY ĐỔI",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}