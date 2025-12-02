import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';

class ProductImagesSlider extends StatelessWidget {
  final String imageUrl;
  final String? heroTag;

  const ProductImagesSlider({super.key, required this.imageUrl, this.heroTag});

  @override
  Widget build(BuildContext context) {
    final image = Image.network(
      imageUrl,
      height: 300, // Tăng chiều cao chút cho đẹp
      width: double.infinity,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const SizedBox(
          height: 300,
          child: Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ),
        );
      },
      errorBuilder: (_, _, _) => const SizedBox(
        height: 300,
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            size: 50,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );

    return Container(
      color: Colors.white,
      child: heroTag != null ? Hero(tag: heroTag!, child: image) : image,
    );
  }
}
