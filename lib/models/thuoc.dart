import 'package:nhathuoc_mobilee/UI/common/constants/api_constants.dart';
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
    // --- XỬ LÝ ẢNH URL ---
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
    // ---------------------

    return Thuoc(
      maThuoc: json['Id'] ?? 0,
      tenThuoc: json['TenThuoc']?.toString() ?? 'Tên đang cập nhật',
      cachSD: json['CachSD']?.toString() ?? '',
      donVi: json['DonVi']?.toString() ?? 'hộp',
      congDung: json['CongDung']?.toString() ?? '',

      // Xử lý giá tiền an toàn
      donGia: (json['GiaBan'] is int)
          ? (json['GiaBan'] as int).toDouble()
          : (json['GiaBan']?.toDouble() ?? 0.0),

      thanhPhan: json['ThanhPhan']?.toString() ?? '',
      loaiThuoc: json['loaiThuoc']?.toString() ?? '',
      nhaCungCap: json['NhaCungCap']?.toString() ?? '',

      // Gán URL đã xử lý ở trên vào đây
      anhURL: finalImageUrl,

      soLuongTon: json['soLuong'] ?? 0,
      khuyenMai: json['KhuyenMai'] != null
          ? KhuyenMai.fromJson(json['KhuyenMai'])
          : null,
    );
  }
}
