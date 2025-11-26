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
    return GioHang(
      maThuoc: _parseInt(json['MaThuoc'] ?? json['maThuoc'], defaultValue: -1),
      tenThuoc: json['TenThuoc'] ?? json['tenThuoc'] ?? '',
      anhURL: json['AnhURL'] ?? json['anhURL'] ?? '',
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
