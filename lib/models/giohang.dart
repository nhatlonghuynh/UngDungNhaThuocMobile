import 'package:nhathuoc_mobilee/UI/common/constants/api_constants.dart';

class GioHang {
  final int maThuoc;
  final String tenThuoc;
  final String anhURL;
  final double donGia;
  final String donVi;
  int soLuong;
  bool isSelected;

  GioHang({
    required this.maThuoc,
    required this.tenThuoc,
    required this.anhURL,
    required this.donGia,
    this.donVi = 'hộp',
    this.soLuong = 1,
    this.isSelected = false,
  });

  // ====== FROM JSON ======
  factory GioHang.fromJson(Map<String, dynamic> json) {
    String rawImage = json['Anh']?.toString() ?? '';
    String finalImageUrl = '';

    if (rawImage.isNotEmpty) {
      // Nếu server trả về link đầy đủ (vd: https://imgur.com/...) thì giữ nguyên
      if (rawImage.startsWith('http')) {
        finalImageUrl = rawImage;
      } else {
        // Nếu server chỉ trả về tên file (vd: "thuoc1.jpg" hoặc "/uploads/thuoc1.jpg")
        // Xóa dấu gạch chéo ở đầu nếu có để tránh bị 2 dấu //
        if (rawImage.startsWith('/')) {
          rawImage = rawImage.substring(1);
        }

        // Ghép chuỗi: http://IP:PORT/path_anh
        // Lưu ý: Không dùng ApiConstants.baseUrl vì nó có đuôi /api
        finalImageUrl = 'http://${ApiConstants.serverUrl}/$rawImage';
      }
    } else {
      // Có thể gán ảnh mặc định nếu không có ảnh
      finalImageUrl = 'https://via.placeholder.com/150';
    }
    return GioHang(
      maThuoc: _parseInt(json['MaThuoc'] ?? json['maThuoc'], defaultValue: -1),
      tenThuoc: json['TenThuoc'] ?? json['tenThuoc'] ?? '',
      anhURL: finalImageUrl,
      donVi: json['DonVi'] ?? json['donVi'] ?? 'hộp',
      donGia: _parseDouble(json['DonGia'] ?? json['donGia'], defaultValue: 0),
      soLuong: _parseInt(json['SoLuong'] ?? json['soLuong'], defaultValue: 1),
    );
  }

  // ====== TO JSON ======
  Map<String, dynamic> toJson() {
    return {
      "MaThuoc": maThuoc,
      "TenThuoc": tenThuoc,
      "AnhURL": anhURL,
      "DonGia": donGia,
      "DonVi": donVi,
      "SoLuong": soLuong,
    };
  }

  // ====== TOTAL PRICE ======
  double get tongTien => donGia * soLuong;

  // ====== Helpers để parse an toàn ======
  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    return int.tryParse(value.toString()) ?? defaultValue;
  }

  static double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    return double.tryParse(value.toString()) ?? defaultValue;
  }
}
