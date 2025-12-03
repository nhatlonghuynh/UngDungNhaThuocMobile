import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/controller/productcontroller.dart';
import 'package:nhathuoc_mobilee/models/thuoc.dart';
import 'package:nhathuoc_mobilee/UI/widgets/Home/product_buy_sheet.dart';
import 'package:nhathuoc_mobilee/UI/widgets/ProductDetail/product_bottom_bar.dart';
import 'package:nhathuoc_mobilee/UI/widgets/ProductDetail/product_images_slider.dart';
import 'package:nhathuoc_mobilee/UI/widgets/ProductDetail/product_info_section.dart';
import 'package:provider/provider.dart';
import 'package:nhathuoc_mobilee/UI/common/widget/loading_state.dart';
import 'package:nhathuoc_mobilee/UI/common/widget/error_state.dart';

class DetailProductScreen extends StatelessWidget {
  final int productId;
  const DetailProductScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductDetailController()..loadProduct(productId),
      child: const _DetailProductView(),
    );
  }
}

class _DetailProductView extends StatelessWidget {
  const _DetailProductView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Chi tiết sản phẩm",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border.withOpacity(0.35)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    offset: const Offset(4, 4),
                    blurRadius: 12,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.9),
                    offset: const Offset(-6, -6),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            ),
          ),
        ),
      ),

      body: Consumer<ProductDetailController>(
        builder: (context, controller, child) {
          // 1. Loading
          if (controller.isLoading) {
            return const LoadingState(
              message: "Đang tải thông tin sản phẩm...",
            );
          }

          // 2. Error
          if (controller.errorMessage.isNotEmpty) {
            return ErrorState(
              message: controller.errorMessage,
              onRetry: () =>
                  controller.loadProduct(controller.product?.maThuoc ?? 0),
            );
          }

          final product = controller.product!;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ProductImagesSlider(imageUrl: product.anh),

                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.background.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppColors.border.withOpacity(0.25),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.textPrimary.withOpacity(0.06),
                                blurRadius: 18,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 14,
                                ),
                                child: ProductInfoSection(
                                  product: product,
                                  finalPrice: controller.finalPrice,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const SizedBox(
                        height: 80,
                      ), // khoảng để tránh che bởi bottom bar
                    ],
                  ),
                ),
              ),

              // Bottom bar
              ProductBottomBar(
                controller: controller,
                onAddToCart: () {
                  if (controller.product == null) return;
                  final detail = controller.product!;
                  // Convert từ ThuocDetail (detail) sang Thuoc (model giỏ hàng)
                  Thuoc thuoc = Thuoc(
                    maThuoc: detail.maThuoc,
                    tenThuoc: detail.tenThuoc,
                    anhURL: detail.anh,
                    cachSD: detail.cachSD,
                    congDung: detail.congDung,
                    donGia: controller.finalPrice,
                    donVi: detail.donVi,
                    loaiThuoc: detail.tenLoai,
                    nhaCungCap: detail.tenNCC,
                    thanhPhan: detail.thanhPhan,
                    soLuongTon: detail.soLuong,
                  );
                  ProductBuySheet.show(context, thuoc, controller.finalPrice);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
