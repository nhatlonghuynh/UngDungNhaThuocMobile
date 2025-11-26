import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/widgets/Home/item_product.dart';
import 'package:provider/provider.dart';
import 'package:nhathuoc_mobilee/controller/product_filter_controller.dart';

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
          ProductFilterController()..loadProducts(typeId: typeId, catId: catId),
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Consumer<ProductFilterController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.message.isNotEmpty) {
              return Center(child: Text(controller.message));
            }

            return GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: controller.products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.70,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                return SanPhamItem(thuoc: controller.products[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
