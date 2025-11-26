import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nhathuoc_mobilee/manager/usermanager.dart';
import 'package:nhathuoc_mobilee/screens/reward_screen.dart';
import 'package:nhathuoc_mobilee/controller/home_controller.dart';
import 'package:nhathuoc_mobilee/common/constants/appcolor.dart';

class HomeHeaderSection extends StatelessWidget {
  const HomeHeaderSection({super.key});
  @override
  Widget build(BuildContext context) {
    final user = UserManager();
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        border: Border.all(color: AppColors.neutralBeige.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutralGrey.withOpacity(0.06),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left: Avatar / welcome
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBackground,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.9),
                  blurRadius: 6,
                  offset: const Offset(-2, -2),
                ),
                BoxShadow(
                  color: AppColors.neutralGrey.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(6, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.local_pharmacy,
              size: 36,
              color: AppColors.primaryPink,
            ),
          ),

          const SizedBox(width: 14),

          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Chào ${user.hoTen},",
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textBrown,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Chúc một ngày tốt lành!",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.neutralGrey,
                  ),
                ),
              ],
            ),
          ),

          // Points chip
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RewardScreen()),
              ).then((_) {
                context.read<HomeController>().fetchProducts();
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.secondaryGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.secondaryGreen.withOpacity(0.14),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryGreen.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.stars,
                    color: AppColors.secondaryGreen,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${user.diemTichLuy}",
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      color: AppColors.textBrown,
                      fontWeight: FontWeight.w700,
                    ),
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

class HomeBannerSection extends StatelessWidget {
  const HomeBannerSection({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.96),
        border: Border.all(color: AppColors.neutralBeige.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutralGrey.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image / icon area (glass card)
          Container(
            width: 92,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryPink.withOpacity(0.12),
                  AppColors.secondaryGreen.withOpacity(0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: AppColors.neutralBeige.withOpacity(0.4),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neutralGrey.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(6, 6),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.local_offer,
                size: 40,
                color: AppColors.primaryPink,
              ),
            ),
          ),

          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "Khuyến mãi đang chạy",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBrown,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Giảm tới 20% các Vitamin ",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.neutralGrey,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          // CTA
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryPink,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPink.withOpacity(0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Text(
              "Xem ngay",
              style: TextStyle(
                fontFamily: 'Inter',
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
