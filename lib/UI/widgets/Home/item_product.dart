import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/UI/screens/detail_product_screen.dart';
import 'package:provider/provider.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/controller/home_controller.dart';
import 'package:nhathuoc_mobilee/models/thuoc.dart';
import 'package:nhathuoc_mobilee/UI/widgets/Home/product_buy_sheet.dart';

class SanPhamItem extends StatelessWidget {
  final Thuoc thuoc;
  const SanPhamItem({super.key, required this.thuoc});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<HomeController>();
    final bool hasPromo = controller.checkPromo(thuoc);
    final double finalPrice = controller.finalPrice(thuoc);

    return GestureDetector(
      onTap: () {
        print("Bấm vào sản phẩm: ${thuoc.tenThuoc} - ID: ${thuoc.maThuoc}");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailProductScreen(productId: thuoc.maThuoc),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.neutralGrey.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.95),
              blurRadius: 8,
              offset: const Offset(-6, -6),
            ),
          ],
          border: Border.all(color: AppColors.neutralBeige.withOpacity(0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                    child: Container(
                      width: double.infinity,
                      color: AppColors.scaffoldBackground,
                      child: Image.network(
                        thuoc.anhURL,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: AppColors.neutralGrey,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // promo badge
                  if (hasPromo)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPink,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryPink.withOpacity(0.14),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Text(
                          controller.badgeText(thuoc),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    thuoc.tenThuoc,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textBrown,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    thuoc.donVi,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.neutralGrey,
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
                              '${controller.formatPrice(thuoc.donGia)}đ',
                              style: const TextStyle(
                                color: AppColors.neutralGrey,
                                fontSize: 11,
                                decoration: TextDecoration.lineThrough,
                                fontFamily: 'Inter',
                              ),
                            ),
                          Text(
                            '${controller.formatPrice(finalPrice)}đ',
                            style: const TextStyle(
                              color: AppColors.primaryPink,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),

                      // Quick buy button (circular)
                      InkWell(
                        onTap: () {
                          ProductBuySheet.show(
                            context,
                            thuoc,
                            controller,
                            finalPrice,
                          );
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPink,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryPink.withOpacity(0.18),
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
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
