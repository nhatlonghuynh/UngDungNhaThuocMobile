import 'package:nhathuoc_mobilee/models/khuyenmai.dart';

class ThuocDetail {
  final int id;
  final String tenThuoc;
  final String donVi;
  final double giaBan;
  final bool trangThai;
  final String anh;
  final String cachSD;
  final String congDung;
  final String thanhPhan;
  final String tenLoai;
  final String tenNCC;
  final int soLuong;
  final KhuyenMai? khuyenMai;

  ThuocDetail({
    required this.id,
    required this.tenThuoc,
    required this.donVi,
    required this.giaBan,
    required this.trangThai,
    required this.anh,
    required this.cachSD,
    required this.congDung,
    required this.thanhPhan,
    required this.tenLoai,
    required this.tenNCC,
    required this.soLuong,
    this.khuyenMai,
  });

  factory ThuocDetail.fromJson(Map<String, dynamic> json) {
    return ThuocDetail(
      id: json['Id'],
      tenThuoc: json['TenThuoc'] ?? '',
      donVi: json['DonVi'] ?? '',
      giaBan: (json['GiaBan'] ?? 0).toDouble(),
      trangThai: json['trangThai'] == "Đang bán",
      anh: json['Anh'] ?? '',
      cachSD: json['CachSD'] ?? 'Đang cập nhật',
      congDung: json['CongDung'] ?? 'Đang cập nhật',
      thanhPhan: json['ThanhPhan'] ?? 'Đang cập nhật',
      tenLoai: json['TenLoai'] ?? '',
      tenNCC: json['TenNCC'] ?? '',
      soLuong: json['soLuong'] ?? 0,
      khuyenMai: json['KhuyenMai'] != null
          ? KhuyenMai.fromJson(json['KhuyenMai'])
          : null,
    );
  }
}
