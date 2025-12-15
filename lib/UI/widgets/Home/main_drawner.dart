import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/controller/categorycontroller.dart';
// Đảm bảo import đúng đường dẫn màn hình Filter
import 'package:nhathuoc_mobilee/UI/screens/filtered_products_screen.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  @override
  void initState() {
    super.initState();
    // Load danh mục ngay khi Drawer được dựng xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryController>().loadCategories();
    });
  }

  void _navigateToFilter(
    BuildContext context,
    String title, {
    int? typeId,
    int? catId,
  }) {
    Navigator.pop(context); // Đóng Drawer trước
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FilteredProductsScreen(title: title, typeId: typeId, catId: catId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dùng watch để vẽ lại khi tree thay đổi (Loading -> Có data)
    final cateController = context.watch<CategoryController>();

    return Drawer(
      child: Container(
        color: AppColors.background,
        child: Column(
          children: [
            // --- HEADER ---
            _buildDrawerHeader(),

            // --- LIST CATEGORY ---
            Expanded(
              child: cateController.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        const SizedBox(height: 12),

                        // Map danh sách danh mục
                        if (cateController.tree.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              "Không có danh mục nào",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),

                        ...cateController.tree.map((loai) {
                          if (loai.danhMucCon.isEmpty) {
                            return ListTile(
                              leading: Image.asset(
                                'assets/icons/drugs1.png',
                                width: 24,
                                height: 24,
                                fit: BoxFit.contain,
                                color: AppColors.badgeNew,
                              ),
                              title: Text(
                                loai.ten,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              onTap: () => _navigateToFilter(
                                context,
                                loai.ten,
                                typeId: loai.id,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 4,
                              ),
                            );
                          }

                          // Trường hợp 2: Có con -> Hiển thị ExpansionTile (Menu xổ xuống)
                          return Theme(
                            // Xóa border mặc định của ExpansionTile khi mở
                            data: Theme.of(
                              context,
                            ).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              leading: Image.asset(
                                'assets/icons/drugs1.png',
                                width: 24,
                                height: 24,
                                fit: BoxFit.contain,
                                color: AppColors.badgeNew,
                              ),
                              title: Text(
                                loai.ten,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              childrenPadding: const EdgeInsets.only(
                                left: 16,
                                bottom: 8,
                              ),
                              children: [
                                // Nút "Tất cả ..."
                                ListTile(
                                  leading: const Icon(
                                    Icons.all_inclusive,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  title: Text(
                                    "Tất cả ${loai.ten}",
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  onTap: () => _navigateToFilter(
                                    context,
                                    loai.ten,
                                    typeId: loai.id,
                                  ),
                                  dense: true,
                                ),
                                // Danh sách con
                                ...loai.danhMucCon.map(
                                  (dm) => ListTile(
                                    leading: Image.asset(
                                      'assets/icons/drugs.png',
                                      height: 18,
                                      width: 18,
                                    ),
                                    title: Text(
                                      dm.ten,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    onTap: () => _navigateToFilter(
                                      context,
                                      dm.ten,
                                      catId: dm.id,
                                    ),
                                    dense: true,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Divider(),
                        ),

                        // Các mục tĩnh khác
                        ListTile(
                          leading: const Icon(
                            Icons.history,
                            color: AppColors.textSecondary,
                          ),
                          title: const Text('Lịch sử mua hàng'),
                          onTap: () {
                            /* TODO */
                          },
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.settings_outlined,
                            color: AppColors.textSecondary,
                          ),
                          title: const Text('Cài đặt'),
                          onTap: () {
                            /* TODO */
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Tách Header ra cho code gọn
  Widget _buildDrawerHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.96),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Image.asset(
              'assets/icons/trolley.png',
              height: 36,
              width: 36,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Nhà Thuốc Online',
              style: TextStyle(
                fontFamily: 'Inter',
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
