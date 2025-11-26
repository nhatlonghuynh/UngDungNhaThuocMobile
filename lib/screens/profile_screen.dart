import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/widgets/profile/user_profile_view.dart';
import 'package:provider/provider.dart';
import 'package:nhathuoc_mobilee/controller/authcontroller.dart';
import 'package:nhathuoc_mobilee/screens/login_screen.dart'; // Widget hiển thị khi đã login
import 'package:nhathuoc_mobilee/common/utils/dialog_helper.dart';

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
            backgroundColor: AppColors.primaryPink,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false, // Ẩn nút back
          ),
          backgroundColor: AppColors.scaffoldBackground,

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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 80,
            color: AppColors.neutralGrey.withOpacity(0.3),
          ),
          const SizedBox(height: 10),
          const Text(
            "Vui lòng đăng nhập để xem hồ sơ",
            style: TextStyle(color: AppColors.neutralGrey, fontSize: 16),
          ),
          const SizedBox(height: 20),
          // Nút đề phòng lỡ tay đóng dialog thì bấm vào đây để mở lại
          TextButton(
            onPressed: () => _checkLoginStatus(),
            child: const Text(
              "Đăng nhập ngay",
              style: TextStyle(
                color: AppColors.primaryPink,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
