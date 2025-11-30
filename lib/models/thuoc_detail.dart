import 'package:nhathuoc_mobilee/UI/common/constants/api_constants.dart';
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
        finalImageUrl =
            'http://${ApiConstants.ipschool}:${ApiConstants.port}/$rawImage';
      }
    } else {
      // Có thể gán ảnh mặc định nếu không có ảnh
      finalImageUrl = 'https://via.placeholder.com/150';
    }
    return ThuocDetail(
      id: json['Id'],
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
