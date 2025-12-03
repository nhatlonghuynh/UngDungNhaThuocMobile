import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/UI/widgets/Home/item_product.dart';
import 'package:provider/provider.dart';
import 'package:nhathuoc_mobilee/controller/product_filter_controller.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/UI/common/widget/loading_state.dart';
import 'package:nhathuoc_mobilee/UI/common/widget/error_state.dart';
import 'package:nhathuoc_mobilee/UI/common/widget/empty_state.dart';
import 'package:nhathuoc_mobilee/locator.dart';
import 'package:nhathuoc_mobilee/api/categoryapi.dart';

class FilteredProductsScreen extends StatelessWidget {
  final String title;
  final int? typeId;
  final int? catId;

  const FilteredProductsScreen({
    super.key,
    required this.title,
    this.typeId,
    this.catId,
  });

  @override
  Widget build(BuildContext context) {
    // Khởi tạo Controller riêng cho màn hình này
    return ChangeNotifierProvider(
      create: (_) =>
          ProductFilterController(service: locator<DanhMucRepository>())
            ..loadProducts(typeId: typeId, catId: catId),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        body: Consumer<ProductFilterController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const LoadingState(message: "Đang tải sản phẩm...");
            }

            if (controller.message.isNotEmpty) {
              return ErrorState(
                message: controller.message,
                onRetry: () =>
                    controller.loadProducts(typeId: typeId, catId: catId),
              );
            }

            if (controller.products.isEmpty) {
              return const EmptyState(
                title: "Không có sản phẩm",
                subtitle: "Không tìm thấy sản phẩm nào trong danh mục này",
                icon: Icons.inventory_2_outlined,
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.70,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemBuilder: (context, index) {
                return SanPhamItem(product: controller.products[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
