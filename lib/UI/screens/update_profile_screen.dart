import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/UI/common/utils/color_opacity_ext.dart';
import 'package:nhathuoc_mobilee/UI/common/utils/dialog_helper.dart';
import 'package:nhathuoc_mobilee/UI/common/widget/custom_text_field.dart';
import 'package:nhathuoc_mobilee/UI/common/widget/primary_button.dart';
import 'package:nhathuoc_mobilee/controller/usercontroller.dart';
import 'package:provider/provider.dart';
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
  late TextEditingController _emailCtrl; // [MỚI] Thêm Email
  late TextEditingController _addressCtrl; // [MỚI] Thêm Địa chỉ

  String? _selectedGender;
  DateTime? _selectedDateObj; // [MỚI] Biến lưu DateTime thực sự để gửi API

  @override
  void initState() {
    super.initState();
    final user = UserManager();

    _nameCtrl = TextEditingController(text: user.hoTen);
    _phoneCtrl = TextEditingController(text: user.soDienThoai);
    _addressCtrl = TextEditingController(text: user.diaChi ?? '');
    _emailCtrl = TextEditingController(text: "user@example.com");
    if (user.ngaySinh != null && user.ngaySinh!.isNotEmpty) {
      _dobCtrl = TextEditingController(text: user.ngaySinh);
      try {
        _selectedDateObj = DateTime.tryParse(user.ngaySinh!);
      } catch (_) {}
    } else {
      _dobCtrl = TextEditingController();
    }

    _selectedGender = user.gioiTinh ?? 'Nam';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  // 1. Hàm chọn ngày sinh
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDateObj ??
          DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateObj = picked; // Lưu Object DateTime
        _dobCtrl.text = DateFormat(
          'yyyy-MM-dd',
        ).format(picked); // Hiển thị String
      });
    }
  }

  // 2. Hàm Submit (Đã cập nhật đủ trường)
  void _handleSubmit(ProfileController controller) async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    // Gọi Controller (đã sửa ở bước trước)
    final result = await controller.updateInfo(
      name: _nameCtrl.text,
      phone: _phoneCtrl.text,
      email: _emailCtrl.text, // [MỚI] Gửi Email
      address: _addressCtrl.text, // [MỚI] Gửi Địa chỉ
      gender: _selectedGender ?? 'Nam',
      dob: _selectedDateObj, // [MỚI] Gửi DateTime object
    );

    if (!mounted) return;

    if (result['success'] == true) {
      DialogHelper.showSuccessDialog(
        context,
        title: "Thành công",
        message: "Cập nhật thông tin thành công!",
        onPressed: () => Navigator.pop(context, true),
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
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
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

                    // 2. SĐT (Readonly)
                    CustomTextField(
                      controller: _phoneCtrl,
                      labelText: "Số điện thoại",
                      prefixIcon: Icons.phone_android_rounded,
                      readOnly: true, // Không cho sửa SĐT đăng nhập
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    // [MỚI] 3. Email
                    CustomTextField(
                      controller: _emailCtrl,
                      labelText: "Email",
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      // validator: (v) => v!.isEmpty ? "Vui lòng nhập email" : null, // Tùy chọn bắt buộc hay không
                    ),
                    const SizedBox(height: 20),

                    // [MỚI] 4. Địa chỉ
                    CustomTextField(
                      controller: _addressCtrl,
                      labelText: "Địa chỉ",
                      prefixIcon: Icons.location_on_outlined,
                      validator: (v) =>
                          v!.isEmpty ? "Vui lòng nhập địa chỉ" : null,
                    ),
                    const SizedBox(height: 20),

                    // 5. Ngày sinh
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

                    // 6. Giới tính
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.border.withOpacity(0.6),
                          width: 1.5,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedGender,
                          decoration: const InputDecoration(
                            labelText: "Giới tính",
                            labelStyle: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            prefixIcon: Icon(
                              Icons.wc_rounded,
                              color: AppColors.primary,
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

              // 7. Nút Lưu
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
