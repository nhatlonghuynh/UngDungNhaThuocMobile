import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/UI/common/utils/dialog_helper.dart';
import 'package:nhathuoc_mobilee/UI/widgets/Profile/user_profile_view.dart';
import 'package:provider/provider.dart';
import 'package:nhathuoc_mobilee/controller/authcontroller.dart';
import 'package:nhathuoc_mobilee/UI/screens/login_screen.dart';
import 'package:nhathuoc_mobilee/UI/common/widget/empty_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthController(),
      child: const ProfileBody(),
    );
  }
}

class ProfileBody extends StatefulWidget {
  const ProfileBody({super.key});

  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  @override
  void initState() {
    super.initState();
    // Kiểm tra trạng thái đăng nhập ngay khi màn hình được vẽ xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  // Logic kiểm tra và điều hướng
  void _checkLoginStatus() async {
    // Lấy controller nhưng KHÔNG lắng nghe (listen: false) vì đang trong hàm logic
    final controller = context.read<AuthController>();

    // Nếu CHƯA đăng nhập
    if (!controller.isLoggedIn) {
      // 1. Hiện Dialog hỏi (Chờ người dùng chọn)
      final bool? shouldLogin = await DialogHelper.showLoginRequirement(
        context,
      );

      // 2. Nếu chọn "Đăng nhập" (true)
      if (shouldLogin == true && mounted) {
        // Chuyển sang màn hình Login và CHỜ kết quả trả về
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
              create: (_) => AuthController(),
              child: const LoginScreen(),
            ),
          ),
        );

        // 3. Nếu Login thành công (LoginScreen trả về true)
        if (result == true && mounted) {
          controller.refresh(); // Refresh để hiện UserProfileView
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ở đây dùng Consumer để lắng nghe thay đổi (khi gọi refresh)
    return Consumer<AuthController>(
      builder: (context, controller, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Hồ sơ cá nhân',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false, // Ẩn nút back
          ),
          backgroundColor: AppColors.background,

          // LOGIC HIỂN THỊ UI:
          // - Nếu đã Login -> Hiện Profile xịn (UserProfileView)
          // - Nếu chưa Login -> Hiện màn hình chờ (FallbackView) để Dialog đè lên
          body: controller.isLoggedIn
              ? UserProfileView(controller: controller)
              : _buildFallbackView(),
        );
      },
    );
  }

  // Màn hình nền khi chưa đăng nhập (nằm dưới Dialog)
  Widget _buildFallbackView() {
    return EmptyState(
      title: "Vui lòng đăng nhập",
      subtitle: "Đăng nhập để xem và quản lý hồ sơ cá nhân",
      icon: Icons.lock_outline_rounded,
      iconColor: AppColors.primary,
      actionButton: ElevatedButton.icon(
        onPressed: () => _checkLoginStatus(),
        icon: const Icon(Icons.login_rounded, size: 20),
        label: const Text(
          "Đăng nhập ngay",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
    );
  }
}
