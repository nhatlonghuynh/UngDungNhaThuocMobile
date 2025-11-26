import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/controller/categorycontroller.dart';
import 'package:nhathuoc_mobilee/UI/screens/filtered_products_screen.dart';
import 'package:provider/provider.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  @override
  void initState() {
    super.initState();
    // Load danh mục khi mở Drawer
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
    Navigator.pop(context); // Đóng Drawer
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
    final cateController = context.watch<CategoryController>();

    return Drawer(
      child: Container(
        color: AppColors.scaffoldBackground,
        child: Column(
          children: [
            // Custom Drawer Header (warm, rounded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.96),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neutralGrey.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: AppColors.neutralBeige.withOpacity(0.5),
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPink.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.local_pharmacy,
                        size: 40,
                        color: AppColors.primaryPink,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Nhà Thuốc HUIT',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: AppColors.textBrown,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: cateController.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        const SizedBox(height: 12),
                        ...cateController.tree.map((loai) {
                          if (loai.danhMucCon.isEmpty) {
                            return ListTile(
                              leading: const Icon(
                                Icons.category,
                                color: AppColors.primaryPink,
                              ),
                              title: Text(
                                loai.ten,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  color: AppColors.textBrown,
                                ),
                              ),
                              onTap: () => _navigateToFilter(
                                context,
                                loai.ten,
                                typeId: loai.id,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 4,
                              ),
                            );
                          }

                          return ExpansionTile(
                            leading: const Icon(
                              Icons.medication,
                              color: AppColors.secondaryGreen,
                            ),
                            title: Text(
                              loai.ten,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                color: AppColors.textBrown,
                              ),
                            ),
                            childrenPadding: const EdgeInsets.only(
                              left: 24,
                              right: 8,
                              bottom: 8,
                            ),
                            children: [
                              ListTile(
                                leading: const Icon(
                                  Icons.all_inclusive,
                                  size: 18,
                                  color: AppColors.primaryPink,
                                ),
                                title: Text(
                                  "Tất cả ${loai.ten}",
                                  style: const TextStyle(
                                    color: AppColors.primaryPink,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                onTap: () => _navigateToFilter(
                                  context,
                                  loai.ten,
                                  typeId: loai.id,
                                ),
                              ),
                              ...loai.danhMucCon.map(
                                (dm) => ListTile(
                                  leading: const Icon(
                                    Icons.arrow_right,
                                    color: AppColors.neutralGrey,
                                  ),
                                  title: Text(
                                    dm.ten,
                                    style: const TextStyle(
                                      color: AppColors.textBrown,
                                    ),
                                  ),
                                  onTap: () => _navigateToFilter(
                                    context,
                                    dm.ten,
                                    catId: dm.id,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Divider(),
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.history,
                            color: AppColors.neutralGrey,
                          ),
                          title: const Text(
                            'Lịch sử mua hàng',
                            style: TextStyle(fontFamily: 'Inter'),
                          ),
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.settings,
                            color: AppColors.neutralGrey,
                          ),
                          title: const Text(
                            'Cài đặt',
                            style: TextStyle(fontFamily: 'Inter'),
                          ),
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
}
