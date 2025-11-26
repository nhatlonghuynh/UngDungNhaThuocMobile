import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/common/constants/appcolor.dart';
import 'package:provider/provider.dart';
import 'package:nhathuoc_mobilee/controller/rewardcontroller.dart';
import 'package:nhathuoc_mobilee/controller/authcontroller.dart';
import 'package:nhathuoc_mobilee/manager/usermanager.dart';
import 'package:nhathuoc_mobilee/screens/login_screen.dart';

// [Module] Import Widget
import 'package:nhathuoc_mobilee/widgets/reward/reward_gift_card.dart';
import 'package:nhathuoc_mobilee/common/utils/dialog_helper.dart';

class RewardScreen extends StatelessWidget {
  const RewardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RewardController()..loadGifts(),
      child: const RewardBody(),
    );
  }
}

class RewardBody extends StatefulWidget {
  const RewardBody({super.key});

  @override
  State<RewardBody> createState() => _RewardBodyState();
}

class _RewardBodyState extends State<RewardBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLogin();
    });
  }

  void _checkLogin() async {
    if (!UserManager().isLoggedIn) {
      final shouldLogin = await DialogHelper.showLoginRequirement(context);

      if (shouldLogin == true && mounted) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
              create: (_) => AuthController(),
              child: const LoginScreen(),
            ),
          ),
        );

        if (result == true && mounted) {
          setState(() {}); // Refresh UI sau khi login thành công
          context.read<RewardController>().loadGifts();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RewardController>();
    final isLoggedIn = UserManager().isLoggedIn;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tích điểm đổi quà",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green, // Màu riêng của màn hình này
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      backgroundColor: AppColors.scaffoldBackground,
      body: !isLoggedIn
          ? _buildGuestView() // [DRY] Hàm UI nhỏ
          : Column(
              children: [
                // 1. Header Điểm
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green, Color(0xFF64DD17)],
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(25),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Điểm tích lũy hiện có",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "${UserManager().diemTichLuy}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "điểm",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Danh sách quà tặng",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBrown,
                      ),
                    ),
                  ),
                ),

                // 2. Grid Quà Tặng
                Expanded(
                  child: controller.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.green),
                        )
                      : controller.gifts.isEmpty
                      ? const Center(child: Text("Chưa có quà tặng nào."))
                      : GridView.builder(
                          padding: const EdgeInsets.all(15),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                              ),
                          itemCount: controller.gifts.length,
                          itemBuilder: (ctx, index) => RewardGiftCard(
                            gift: controller.gifts[index],
                            controller: controller,
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildGuestView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.card_giftcard, size: 100, color: Colors.green[100]),
          const SizedBox(height: 20),
          const Text(
            "Đăng nhập để đổi quà!",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _checkLogin(), // Gọi lại hàm check
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: const Text(
              "ĐĂNG NHẬP NGAY",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
