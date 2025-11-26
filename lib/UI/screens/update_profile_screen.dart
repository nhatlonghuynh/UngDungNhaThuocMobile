import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/UI/common/utils/dialog_helper.dart';
import 'package:nhathuoc_mobilee/UI/common/widget/custom_text_field.dart';
import 'package:nhathuoc_mobilee/UI/common/widget/primary_button.dart';
import 'package:provider/provider.dart';
import 'package:nhathuoc_mobilee/controller/usercontroller.dart';
import 'package:nhathuoc_mobilee/manager/usermanager.dart';
import 'package:nhathuoc_mobilee/UI/common/widget/glass_card.dart';

class UpdateProfileScreen extends StatelessWidget {
  const UpdateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileController(),
      child: const UpdateProfileView(),
    );
  }
}

class UpdateProfileView extends StatefulWidget {
  const UpdateProfileView({super.key});

  @override
  State<UpdateProfileView> createState() => _UpdateProfileViewState();
}

class _UpdateProfileViewState extends State<UpdateProfileView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _dobCtrl;

  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    final user = UserManager();
    _nameCtrl = TextEditingController(text: user.hoTen);
    _phoneCtrl = TextEditingController(text: user.soDienThoai);
    // Nếu ngày sinh null thì để trống
    _dobCtrl = TextEditingController(text: user.ngaySinh ?? '');
    _selectedGender = user.gioiTinh ?? 'Nam';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  // 1. Hàm chọn ngày sinh
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 365 * 18),
      ), // Mặc định 18 tuổi
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryPink,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // 2. Hàm Submit (Đã bỏ tham số Address)
  void _handleSubmit(ProfileController controller) async {
    if (!_formKey.currentState!.validate()) return;

    // Ẩn bàn phím
    FocusScope.of(context).unfocus();

    final result = await controller.updateInfo(
      name: _nameCtrl.text,
      phone: _phoneCtrl.text,
      gender: _selectedGender ?? 'Nam',
      birthday: _dobCtrl.text,
    );

    if (!mounted) return;

    if (result['success']) {
      DialogHelper.showSuccessDialog(
        context,
        title: "Thành công",
        message: "Cập nhật thông tin thành công!",
        onPressed: () => Navigator.pop(context, true), // Trả về true để reload
      );
    } else {
      DialogHelper.showError(context, message: result['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProfileController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Cập nhật thông tin",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryPink,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: AppColors.scaffoldBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 8),
              GlassCard(
                padding: const EdgeInsets.all(24),
                borderRadius: 24,
                child: Column(
                  children: [
                    // 1. Họ tên
                    CustomTextField(
                      controller: _nameCtrl,
                      labelText: "Họ và tên",
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (v) =>
                          v!.isEmpty ? "Vui lòng nhập họ tên" : null,
                    ),
                    const SizedBox(height: 20),

                    // 2. SĐT
                    CustomTextField(
                      controller: _phoneCtrl,
                      labelText: "Số điện thoại",
                      prefixIcon: Icons.phone_android_rounded,
                      keyboardType: TextInputType.phone,
                      readOnly: true,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    // 3. Ngày sinh (Chọn lịch)
                    GestureDetector(
                      onTap: _selectDate,
                      child: AbsorbPointer(
                        child: CustomTextField(
                          controller: _dobCtrl,
                          labelText: "Ngày sinh",
                          prefixIcon: Icons.calendar_today_outlined,
                          validator: (v) =>
                              v!.isEmpty ? "Vui lòng chọn ngày sinh" : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 4. Giới tính (Dropdown với GlassCard style)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.neutralBeige.withOpacity(0.6),
                          width: 1.5,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<String>(
                          value: _selectedGender,
                          decoration: const InputDecoration(
                            labelText: "Giới tính",
                            labelStyle: TextStyle(
                              color: AppColors.neutralGrey,
                              fontWeight: FontWeight.w500,
                            ),
                            prefixIcon: Icon(
                              Icons.wc_rounded,
                              color: AppColors.primaryPink,
                            ),
                            border: InputBorder.none,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Nam', child: Text('Nam')),
                            DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
                          ],
                          onChanged: (v) => setState(() => _selectedGender = v),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 5. Nút Lưu
              PrimaryButton(
                text: "LƯU THAY ĐỔI",
                isLoading: controller.isLoading,
                onPressed: () => _handleSubmit(controller),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
