import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/controller/home_controller.dart';
import 'package:nhathuoc_mobilee/models/thuoc.dart';
import 'package:nhathuoc_mobilee/widgets/Home/product_buy_sheet.dart';
import 'package:nhathuoc_mobilee/widgets/ProductDetail/product_bottom_bar.dart';
import 'package:nhathuoc_mobilee/widgets/ProductDetail/product_images_slider.dart';
import 'package:nhathuoc_mobilee/widgets/ProductDetail/product_info_section.dart';
import 'package:provider/provider.dart';
import 'package:nhathuoc_mobilee/controller/productcontroller.dart';

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
      backgroundColor: AppColors.scaffoldBackground,
      // Dùng AppBar trong suốt, phần back button nổi theo phong cách glassmorphism
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Chi tiết sản phẩm",
          style: TextStyle(
            color: AppColors.textBrown,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        automaticallyImplyLeading: false,
        // custom leading để giữ control wyglądu
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.scaffoldBackground.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.neutralGrey.withOpacity(0.35),
                ),
                boxShadow: [
                  // nhẹ Neumorphism
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
              child: Icon(Icons.arrow_back, color: AppColors.textBrown),
            ),
          ),
        ),
      ),

      body: Consumer<ProductDetailController>(
        builder: (context, controller, child) {
          // 1. Loading
          if (controller.isLoading) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.neutralBeige.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textBrown.withOpacity(0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const CircularProgressIndicator(
                  color: AppColors.primaryPink,
                ),
              ),
            );
          }

          // 2. Error
          if (controller.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 52,
                    color: AppColors.primaryPink,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    controller.errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textBrown),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.primaryPink.withOpacity(0.12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                    ),
                    onPressed: () =>
                        controller.loadProduct(controller.product?.id ?? 0),
                    child: Text(
                      "Thử lại",
                      style: TextStyle(
                        color: AppColors.primaryPink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final product = controller.product!;

          return Column(
            children: [
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Ảnh chính với nền warm gradient + neumorphism card
                      ProductImagesSlider(imageUrl: product.anh),

                      const SizedBox(height: 14),

                      // Card thông tin sản phẩm - glassmorphism style
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.scaffoldBackground.withOpacity(
                              0.9,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppColors.neutralGrey.withOpacity(0.25),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.textBrown.withOpacity(0.06),
                                blurRadius: 18,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Reuse existing ProductInfoSection (UI nội dung), nhưng bọc trong padding đẹp
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

                      // Thông tin thêm (ví dụ mô tả dài) - giữ structure nếu ProductInfoSection đã cover
                      // Nếu cần thêm sections, người dùng có thể chỉnh ProductInfoSection (không đổi ở đây).
                      const SizedBox(
                        height: 80,
                      ), // khoảng để tránh che bởi bottom bar
                    ],
                  ),
                ),
              ),

              // Bottom bar (đã tách file) - vẫn sử dụng ProductBottomBar
              ProductBottomBar(
                controller: controller,
                onAddToCart: () {
                  if (controller.product == null) return;
                  final detail = controller.product!;
                  Thuoc thuoc = Thuoc(
                    maThuoc: detail.id,
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
                  ProductBuySheet.show(
                    context,
                    thuoc, // Truyền đối tượng đã convert
                    context
                        .read<
                          HomeController
                        >(), // Truyền Controller (hoặc tạo mới nếu chỉ dùng hàm format giá)
                    controller.finalPrice, // Truyền giá tiền
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
