import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/controller/authcontroller.dart';
import 'package:nhathuoc_mobilee/manager/usermanager.dart';
import 'package:nhathuoc_mobilee/UI/screens/changepassword_screen.dart';
import 'package:nhathuoc_mobilee/UI/screens/history_screen.dart';
import 'package:nhathuoc_mobilee/UI/screens/reward_screen.dart'; // Import Reward Screen
import 'package:nhathuoc_mobilee/UI/common/utils/dialog_helper.dart';
import 'package:nhathuoc_mobilee/UI/screens/update_profile_screen.dart'; // [DRY]

class UserProfileView extends StatelessWidget {
  final AuthController controller;

  const UserProfileView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final user = UserManager();

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
            color: AppColors.primaryPink,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: AppColors.primaryPink,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.hoTen,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        user.soDienThoai,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          const SizedBox(height: 10),

          // 1. Điểm tích lũy
          _buildMenuItem(
            icon: Icons.loyalty,
            iconColor: Colors.orange,
            title: "Điểm tích lũy: ${user.diemTichLuy}",
            subtitle: "Đổi quà ngay",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RewardScreen()),
              );
            },
          ),

          const SizedBox(height: 10),

          // 2. Cập nhật thông tin
          _buildMenuItem(
            icon: Icons.edit,
            iconColor: Colors.blue,
            title: "Cập nhật thông tin",
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UpdateProfileScreen()),
              );
              if (result == true) controller.refresh();
            },
          ),
          const Divider(height: 1, indent: 60),

          // 3. Lịch sử đơn hàng
          _buildMenuItem(
            icon: Icons.history,
            iconColor: Colors.green,
            title: "Lịch sử đơn hàng",
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => OrderHistoryScreen()),
              );
              if (result == true) controller.refresh();
            },
          ),
          const Divider(height: 1, indent: 60),

          // 4. Đổi mật khẩu
          _buildMenuItem(
            icon: Icons.lock_outline,
            iconColor: Colors.grey,
            title: "Đổi mật khẩu",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
              );
            },
          ),

          const SizedBox(height: 30),

          // Nút Đăng xuất
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  // [DRY] Dialog xác nhận đăng xuất
                  final confirm = await DialogHelper.showConfirmDialog(
                    context,
                    title: "Đăng xuất",
                    content: "Bạn có chắc chắn muốn đăng xuất?",
                    confirmText: "Đăng xuất",
                    confirmColor: Colors.red,
                  );

                  if (confirm == true) {
                    controller.logout();
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text("Đăng xuất"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // Helper Widget nhỏ gọn cho Menu Item
  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(color: Colors.blue, fontSize: 12),
              )
            : null,
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.neutralGrey,
        ),
        onTap: onTap,
      ),
    );
  }
}
