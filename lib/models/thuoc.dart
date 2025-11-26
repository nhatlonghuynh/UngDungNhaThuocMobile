import 'package:nhathuoc_mobilee/models/khuyenmai.dart';

class Thuoc {
  final int maThuoc;
  final String tenThuoc;
  final String cachSD;
  final String donVi;
  final String congDung;
  final String thanhPhan;
  final double donGia;
  final String loaiThuoc;
  final String nhaCungCap;
  final String anhURL;
  final int soLuongTon;
  final KhuyenMai? khuyenMai;

  Thuoc({
    required this.maThuoc,
    required this.tenThuoc,
    required this.cachSD,
    required this.donVi,
    required this.congDung,
    required this.donGia,
    required this.thanhPhan,
    required this.loaiThuoc,
    required this.nhaCungCap,
    required this.anhURL,
    this.soLuongTon = 0,
    this.khuyenMai,
  });

  // To Json: Dùng khi cần gửi data lên server (nếu cần)
  Map<String, dynamic> toJson() {
    return {
      'maThuoc': maThuoc,
      'tenThuoc': tenThuoc,
      'donGia': donGia,
      'anhURL': anhURL,
      'donVi': donVi,
    };
  }

  // From Json: Đã thêm kiểm tra null an toàn (Safe Parsing)
  factory Thuoc.fromJson(Map<String, dynamic> json) {
    return Thuoc(
      maThuoc: json['Id'] ?? 0, // Nếu null thì lấy 0
      tenThuoc: json['TenThuoc']?.toString() ?? 'Tên đang cập nhật',
      cachSD: json['CachSD']?.toString() ?? '',
      donVi: json['DonVi']?.toString() ?? 'hộp',
      congDung: json['CongDung']?.toString() ?? '',
      // Xử lý giá tiền an toàn dù server trả về int hay double
      donGia: (json['GiaBan'] is int)
          ? (json['GiaBan'] as int).toDouble()
          : (json['GiaBan']?.toDouble() ?? 0.0),
      thanhPhan: json['ThanhPhan']?.toString() ?? '',
      loaiThuoc: json['loaiThuoc']?.toString() ?? '',
      nhaCungCap: json['NhaCungCap']?.toString() ?? '',
      anhURL: json['Anh']?.toString() ?? '',
      soLuongTon: json['soLuong'] ?? 0,
      khuyenMai: json['KhuyenMai'] != null
          ? KhuyenMai.fromJson(json['KhuyenMai'])
          : null,
    );
  }
}
