class KhuyenMai {
  final String tenKM;
  final double tienGiam;
  final String ngayBD;
  final String ngayKT;
  final double phanTramKM;
  KhuyenMai({
    required this.tenKM,
    this.tienGiam = 0,
    required this.ngayBD,
    required this.ngayKT,
    this.phanTramKM = 0,
    s,
  });

  factory KhuyenMai.fromJson(Map<String, dynamic> json) {
    return KhuyenMai(
      tenKM: json['TenKM']?.toString() ?? '',
      tienGiam: (json['GiaTri'] ?? 0).toDouble(),
      ngayBD: json['NgayBD'] ?? '',
      ngayKT: json['NgayKT'] ?? '',
      phanTramKM: (json['PhanTramKM'] ?? 0).toDouble(),
    );
  }
}
