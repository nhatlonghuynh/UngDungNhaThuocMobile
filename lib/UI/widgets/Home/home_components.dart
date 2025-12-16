import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/UI/common/utils/color_opacity_ext.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:shimmer/shimmer.dart';
import 'package:nhathuoc_mobilee/manager/usermanager.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/api_constants.dart';
import 'package:nhathuoc_mobilee/UI/screens/reward_screen.dart';
import 'package:nhathuoc_mobilee/controller/home_controller.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';

class HomeHeaderSection extends StatelessWidget {
  const HomeHeaderSection({super.key});
  @override
  Widget build(BuildContext context) {
    final userMgr = context.watch<UserManager>();
    final user = UserManager();
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.98),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
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
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.surface.withOpacity(0.9),
                  blurRadius: 6,
                  offset: const Offset(-2, -2),
                ),
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 10,
                  offset: const Offset(6, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 36,
              color: AppColors.primary,
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
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Chúc một ngày tốt lành!",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.textSecondary,
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
                color: AppColors.secondary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.secondary.withOpacity(0.14),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars, color: AppColors.secondary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    "${userMgr.diemTichLuy}",
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      color: AppColors.textPrimary,
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

class HomeBannerSection extends StatefulWidget {
  const HomeBannerSection({super.key});

  @override
  State<HomeBannerSection> createState() => _HomeBannerSectionState();
}

class _HomeBannerSectionState extends State<HomeBannerSection> {
  final PageController _controller = PageController(viewportFraction: 0.95);
  late Timer _timer;
  int _current = 0;

  // Slides may optionally include an 'image' key with a full URL or relative path.
  // If provided, the banner will load the image from assets (preferred) or network.
  final List<Map<String, String>> _slides = [
    {
      'title': 'Khuyến mãi đang chạy',
      'subtitle': '20% các Vitamin',
      // Example asset path: 'assets/images/slider/banner1.jpg'
      // Example server path: '/images/slider/banner1.jpg'
    },
    {'title': 'Mua 1 tặng 1', 'subtitle': ' trong tuần'},
    {'title': 'Miễn phí giao hàng', 'subtitle': 'Trên 200k'},
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      _current = (_current + 1) % _slides.length;
      _controller.animateToPage(
        _current,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: _controller,
        itemCount: _slides.length,
        onPageChanged: (i) => setState(() => _current = i),
        itemBuilder: (context, index) {
          final slide = _slides[index];
          final bool active = index == _current;
          return GestureDetector(
            onTap: () {},
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              margin: EdgeInsets.symmetric(
                horizontal: active ? 6 : 10,
                vertical: active ? 6 : 12,
              ),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.14 + (active ? 0.06 : 0)),
                    AppColors.secondary.withOpacity(0.06 + (active ? 0.04 : 0)),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: AppColors.border.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(active ? 0.18 : 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 110,
                    height: double.infinity,
                    margin: const EdgeInsets.only(right: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withOpacity(0.04),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Builder(
                        builder: (context) {
                          final raw = slide['image'];
                          String? imageUrl;
                          String? assetPath;

                          if (raw != null && raw.isNotEmpty) {
                            final r = raw.trim();
                            // Prefer local assets when path indicates slider assets
                            if (r.startsWith('assets/') ||
                                r.contains('images/slider')) {
                              if (r.startsWith('/')) {
                                assetPath = r.substring(1);
                              } else if (r.startsWith('assets/')) {
                                assetPath = r;
                              } else {
                                assetPath = 'assets/' + r;
                              }
                            } else if (r.startsWith('http')) {
                              imageUrl = r;
                            } else if (r.startsWith('/')) {
                              imageUrl = ApiConstants.serverUrl + r;
                            } else {
                              imageUrl = ApiConstants.serverUrl + '/' + r;
                            }
                          }

                          if (assetPath != null && assetPath.isNotEmpty) {
                            return Image.asset(
                              assetPath,
                              fit: BoxFit.cover,
                              width: 110,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Colors.grey.shade200,
                                    child: const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                            );
                          }

                          if (imageUrl != null && imageUrl.isNotEmpty) {
                            return Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: 110,
                              height: double.infinity,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Shimmer.fromColors(
                                      baseColor: Colors.grey.shade300,
                                      highlightColor: Colors.grey.shade100,
                                      child: Container(
                                        color: Colors.grey.shade300,
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Colors.grey.shade200,
                                    child: const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                            );
                          }

                          return Center(
                            child: Icon(
                              Icons.local_offer,
                              size: 40,
                              color: AppColors.primary,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          slide['title']!,
                          maxLines: 2, // Cho phép tối đa 2 dòng tiêu đề
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize:
                                16, // Tăng nhẹ size chữ vì đã có chỗ trống
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8), // Tăng khoảng cách dòng
                        Text(
                          slide['subtitle']!,
                          maxLines: 2, // Cho phép mô tả dài hơn (2 dòng)
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.4, // Giãn dòng cho dễ đọc
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
