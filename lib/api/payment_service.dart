import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nhathuoc_mobilee/manager/usermanager.dart';
import 'package:nhathuoc_mobilee/models/giohang.dart';

class PaymentService {
  final String baseUrl = 'http://192.168.2.9:8476/api/order';

  // ==========================================================
  // Helper: Lấy Token đăng nhập
  // ----------------------------------------------------------
  // Dùng cho tất cả API yêu cầu xác thực
  // Ném Exception khi token hết hạn
  // ==========================================================
  Future<String> _getToken() async {
    String? token = UserManager().accessToken;

    if (token == null || token.isEmpty) {
      throw Exception("Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.");
    }
    return token;
  }

  // ==========================================================
  // 1. Tạo đơn hàng tạm
  // ----------------------------------------------------------
  // Gọi API: POST /order/tao-don-tam
  // Truyền danh sách sản phẩm, ghi chú, giảm giá & phương thức thanh toán
  // Trả về Map<String, dynamic> theo response Backend
  // ==========================================================
  Future<Map<String, dynamic>> createOrder({
    required List<GioHang> items,
    required String note,
    required double voucherDiscount,
    required double pointDiscount,
    required String paymentMethod,
  }) async {
    final token = await _getToken();

    // Chuẩn bị danh sách sản phẩm
    final listSanPhams = items.map((item) {
      return {
        "MaSP": item.maThuoc,
        "SoLuong": item.soLuong,
        "GiaThucTe": item.donGia,
      };
    }).toList();

    final requestBody = {
      "MaKH": UserManager().userId,
      "GhiChu": note,
      "GiamGiaVoucher": voucherDiscount,
      "GiamGiaDiem": pointDiscount,
      "SanPhams": listSanPhams,
      "PhuongThucThanhToan": paymentMethod,
    };

    final url = Uri.parse('$baseUrl/tao-don-tam');

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(requestBody),
    );

    return _handleResponse(response);
  }

  // ==========================================================
  // 2. Xác nhận thanh toán PayOS
  // ----------------------------------------------------------
  // Gọi API: POST /order/webhook
  // Gửi MaHD + PayOSOrderCode để xác nhận đơn thanh toán
  // Ném exception khi thất bại
  // ==========================================================
  Future<void> confirmPayment(int maHD, int payOSOrderCode) async {
    final token = await _getToken();

    final url = Uri.parse('$baseUrl/webhook');

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"MaHD": maHD, "PayOSOrderCode": payOSOrderCode}),
    );

    if (response.statusCode != 200) {
      final err = jsonDecode(response.body);
      throw Exception(err["Message"] ?? "Không thể xác nhận thanh toán");
    }
  }

  // ==========================================================
  // 3. Xử lý Response dùng chung
  // ----------------------------------------------------------
  // Trả về JSON khi statusCode = 200
  // Khi lỗi: cố đọc message Backend, fallback nếu không có
  // ==========================================================
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    try {
      final error = jsonDecode(response.body);
      throw Exception(
        error['Message'] ?? "Lỗi không xác định (${response.statusCode})",
      );
    } catch (_) {
      throw Exception("Lỗi server: ${response.statusCode}");
    }
  }
}
