import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/UI/common/utils/color_opacity_ext.dart';
import 'package:nhathuoc_mobilee/UI/screens/detail_product_screen.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/service/productservice.dart';
import 'package:nhathuoc_mobilee/models/thuoc.dart';
import 'package:nhathuoc_mobilee/UI/widgets/Home/product_buy_sheet.dart';
import 'package:shimmer/shimmer.dart';

class SanPhamItem extends StatefulWidget {
  final Thuoc product;
  const SanPhamItem({super.key, required this.product});

  @override
  State<SanPhamItem> createState() => _SanPhamItemState();
}

class _SanPhamItemState extends State<SanPhamItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final double finalPrice = ProductService.getDiscountedPrice(product);
    final bool hasPromo = ProductService.hasPromotion(product);

    // Tính phần trăm giảm giá để hiển thị
    int discountPercent = 0;
    if (product.donGia > 0 && hasPromo) {
      discountPercent = ((product.donGia - finalPrice) / product.donGia * 100)
          .round();
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onHighlightChanged: (v) => setState(() => _pressed = v),
        onTap: () {
          print(
            "Bấm vào sản phẩm: ${product.tenThuoc} - ID: ${product.maThuoc}",
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DetailProductScreen(productId: product.maThuoc),
            ),
          );
        },
        child: AnimatedScale(
          scale: _pressed ? 0.985 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCirc,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: AppColors.surface.withOpacity(0.95),
                  blurRadius: 8,
                  offset: const Offset(-6, -6),
                ),
              ],
              border: Border.all(color: AppColors.border.withOpacity(0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image area - SỬA Ở ĐÂY: Dùng Stack để đè badge khuyến mãi lên ảnh
                Expanded(
                  child: Stack(
                    children: [
                      // 1. Ảnh nền (Giữ nguyên logic cũ)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(22),
                        ),
                        child: Container(
                          width: double.infinity,
                          color: Colors.white,
                          child: product.anhURL.isEmpty
                              ? _buildErrorWidget()
                              : Image.network(
                                  product.anhURL,
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                  height: double.infinity,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Shimmer.fromColors(
                                          baseColor: Colors.grey[300]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Container(color: Colors.white),
                                        );
                                      },
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildErrorWidget();
                                  },
                                ),
                        ),
                      ),

                      // 2. Badge khuyến mãi (Màu đỏ)
                      if (hasPromo && discountPercent > 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red, // Màu đỏ theo yêu cầu
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '-$discountPercent%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Info (Giữ nguyên)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.tenThuoc,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.donVi,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (hasPromo)
                                Text(
                                  '${ProductService.formatMoney(product.donGia)}đ',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                    decoration: TextDecoration.lineThrough,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              Text(
                                '${ProductService.formatMoney(finalPrice)}đ',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),

                          // Quick buy button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                ProductBuySheet.show(
                                  context,
                                  product,
                                  finalPrice,
                                );
                              },
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(
                                        0.18,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[100],
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported,
        color: AppColors.textSecondary,
        size: 40,
      ),
    );
  }
}
