import 'package:flutter/material.dart';

class AppColors {
  // Màu chủ đạo: Cam đào ấm áp, nổi bật nhưng vẫn dịu mắt và chuyên nghiệp
  static const Color primaryPink = Color.fromARGB(
    255,
    16,
    151,
    236,
  ); // từ hồng san hô chuyển sang cam đỏ ấm hơn

  // Màu bổ trợ: Xanh lá non tươi sáng, tượng trưng cho sức khỏe, thuốc men, sự sống
  static const Color secondaryGreen = Color.fromRGBO(
    255,
    200,
    0,
    1,
  ); // xanh lá ngọc tươi sáng, năng lượng tích cực

  // Màu chữ chính: Nâu cà phê ấm, dễ đọc, tạo cảm giác đáng tin cậy
  static const Color textBrown = Color(
    0xFF5D4037,
  ); // nâu đậm hơn một chút, rất hợp tông ấm

  // Màu xám trung tính: Xám ấm (warm grey) thay vì xám lạnh
  static const Color neutralGrey = Color.fromARGB(
    255,
    127,
    191,
    255,
  ); // xám be nhẹ, không lạnh

  // Màu viền, divider: Be nâu nhạt rất ấm và sang
  static const Color neutralBeige = Color.fromARGB(
    255,
    121,
    183,
    221,
  ); // be kem ấm áp

  // Màu nền app: Trắng kem nhẹ thay vì trắng tinh, tạo cảm giác ấm cúng như nhà thuốc truyền thống
  static const Color scaffoldBackground = Color.fromARGB(
    255,
    144,
    220,
    255,
  ); // kem nhạt cực ấm
}
