import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/common/constants/appcolor.dart';

class ProductImagesSlider extends StatelessWidget {
  final String imageUrl;

  const ProductImagesSlider({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Image.network(
        imageUrl,
        height: 300, // Tăng chiều cao chút cho đẹp
        width: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const SizedBox(
          height: 300,
          child: Center(
            child: Icon(Icons.image_not_supported, size: 50, color: AppColors.neutralGrey),
          ),
        ),
      ),
    );
  }
}