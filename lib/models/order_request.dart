class SanPhamDatHang {
  final int maSP;
  final int soLuong;
  final double giaThucTe;

  SanPhamDatHang({
    required this.maSP,
    required this.soLuong,
    required this.giaThucTe,
  });

  // Chuyển đổi sang JSON để gửi API
  Map<String, dynamic> toJson() => {
    "MaSP": maSP,
    "SoLuong": soLuong,
    "GiaThucTe": giaThucTe,
  };
}

class TaoDonHangRequest {
  final String maKH; // Lưu ý: Dùng String theo UserManager mới
  final String ghiChu;
  final double giamGiaVoucher;
  final double giamGiaDiem;
  final List<SanPhamDatHang> sanPhams;

  TaoDonHangRequest({
    required this.maKH,
    required this.ghiChu,
    required this.giamGiaVoucher,
    required this.giamGiaDiem,
    required this.sanPhams,
  });

  Map<String, dynamic> toJson() => {
    "MaKH": maKH,
    "GhiChu": ghiChu,
    "GiamGiaVoucher": giamGiaVoucher,
    "GiamGiaDiem": giamGiaDiem,
    "SanPhams": sanPhams.map((e) => e.toJson()).toList(),
  };
}
