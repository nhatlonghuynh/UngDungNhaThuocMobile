class OrderSummary {
  final int maHD;
  final DateTime ngayTao;
  final String trangThai;
  final String hinhThucNhan;
  final double tongTien;
  // Thông tin thuốc đầu tiên để hiển thị preview
  final String tenThuocDau;
  final int soLuongThuocDau;
  final double tienThuocDau;
  final int tongSoLuongSanPham;

  OrderSummary({
    required this.maHD,
    required this.ngayTao,
    required this.trangThai,
    required this.hinhThucNhan,
    required this.tongTien,
    required this.tenThuocDau,
    required this.soLuongThuocDau,
    required this.tienThuocDau,
    this.tongSoLuongSanPham = 0,
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    // Xử lý trường hợp null nếu đơn hàng rỗng (dù hiếm)
    var firstItem = json['ThuocDauTien'] ?? {};
    return OrderSummary(
      maHD: json['MaHD'],
      ngayTao: DateTime.tryParse(json['NgayTao'] ?? '') ?? DateTime.now(),
      trangThai: json['TrangThai'] ?? 'Không xác định',
      hinhThucNhan: json['HinhThucNhan'] ?? 'Chưa cập nhật',
      tongTien: (json['TongTien'] ?? 0).toDouble(),
      tenThuocDau: firstItem['TenThuoc'] ?? '',
      soLuongThuocDau: firstItem['SoLuong'] ?? 0,
      tienThuocDau: (firstItem['Tien'] ?? 0).toDouble(),
      // Nếu API C# chưa trả về tổng số lượng, bạn có thể mặc định hoặc bổ sung vào DTO sau
      tongSoLuongSanPham: 1,
    );
  }
}

class OrderDetail {
  final int maHD;
  final DateTime ngayTao;
  final String trangThai;
  final String hinhThucNhan;
  final double tongTien;
  final String diaChiNhanHang;
  final String nguoiNhan;
  final String sdt;
  final List<OrderItem> chiTiet;

  OrderDetail({
    required this.maHD,
    required this.ngayTao,
    required this.trangThai,
    required this.hinhThucNhan,
    required this.tongTien,
    required this.diaChiNhanHang,
    required this.nguoiNhan,
    required this.sdt,
    required this.chiTiet,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      maHD: json['MaHD'],
      ngayTao: DateTime.tryParse(json['NgayTao'] ?? '') ?? DateTime.now(),
      trangThai: json['TrangThai'] ?? '',
      hinhThucNhan: json['HinhThucNhan'] ?? '',
      tongTien: (json['TongTien'] ?? 0).toDouble(),
      diaChiNhanHang: json['DiaChiNhanHang'] ?? 'Tại cửa hàng',
      nguoiNhan: json['ThongTinNguoiNhan']?['HoTen'] ?? '',
      sdt: json['ThongTinNguoiNhan']?['SDT'] ?? '',
      chiTiet: (json['ChiTiet'] as List? ?? [])
          .map((e) => OrderItem.fromJson(e))
          .toList(),
    );
  }
}

class OrderItem {
  final int maThuoc;
  final String tenThuoc;
  final int soLuong;
  final double donGia;
  final double thanhTien;

  OrderItem({
    required this.maThuoc,
    required this.tenThuoc,
    required this.soLuong,
    required this.donGia,
    required this.thanhTien,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      maThuoc: json['MaThuoc'] ?? 0,
      tenThuoc: json['TenThuoc'] ?? '',
      soLuong: json['SoLuong'] ?? 0,
      donGia: (json['DonGia'] ?? 0).toDouble(),
      thanhTien: (json['Tien'] ?? 0).toDouble(),
    );
  }
}
