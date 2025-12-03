import 'package:nhathuoc_mobilee/UI/common/constants/api_constants.dart';
import 'package:nhathuoc_mobilee/models/khuyenmai.dart';

class ThuocDetail {
  final int maThuoc;
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
    required this.maThuoc,
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
    String rawImage = json['Anh']?.toString() ?? '';
    String finalImageUrl = '';

    if (rawImage.isNotEmpty) {
      if (rawImage.startsWith('http')) {
        finalImageUrl = rawImage;
      } else {
        if (rawImage.startsWith('/')) {
          rawImage = rawImage.substring(1);
        }
        finalImageUrl = '${ApiConstants.serverUrl}/$rawImage';
      }
    } else {
      finalImageUrl = 'https://via.placeholder.com/150';
    }
    return ThuocDetail(
      maThuoc: json['Id'],
      tenThuoc: json['TenThuoc'] ?? '',
      donVi: json['DonVi'] ?? '',
      giaBan: (json['GiaBan'] ?? 0).toDouble(),
      trangThai: json['trangThai'] == "Đang bán",
      anh: finalImageUrl,
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
