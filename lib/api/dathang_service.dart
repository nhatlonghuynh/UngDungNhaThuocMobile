import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nhathuoc_mobilee/UI/common/constants/api_constants.dart';
import 'package:nhathuoc_mobilee/manager/usermanager.dart';
import 'package:nhathuoc_mobilee/models/order_request.dart';

class OrderRepository {
  /// =========================================================
  /// Hàm: createOrder
  /// Tác dụng: Gửi request tạo đơn hàng mới lên Server.
  /// Input: TaoDonHangRequest (Chứa danh sách thuốc, tổng tiền, địa chỉ...)
  /// Output: Map kết quả chứa {success: true/false, message: "thông báo"}
  /// =========================================================
  Future<Map<String, dynamic>> createOrder(TaoDonHangRequest request) async {
    try {
      // 1. Lấy Token xác thực người dùng (từ UserManager đã lưu lúc đăng nhập)
      String? token = UserManager().accessToken;

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.',
        };
      }

      // 2. Tạo URL từ ApiConstants
      // URL cũ: .../api/order/tao-don-tam
      // URL mới: ${ApiConstants.baseUrl}/order/tao-don-tam
      final url = Uri.parse('${ApiConstants.baseUrl}/order/tao-don-tam');

      // 3. Gọi API POST
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization":
              "Bearer $token", // Quan trọng: Gửi kèm Token để Server biết ai mua
        },
        body: jsonEncode(
          request.toJson(),
        ), // Đóng gói dữ liệu đơn hàng thành JSON
      );

      // 4. Xử lý kết quả trả về
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Đặt hàng thành công!'};
      } else {
        // Parse lỗi từ Server trả về (nếu có)
        String errorMsg = "Tạo đơn hàng thất bại";
        try {
          final body = jsonDecode(response.body);
          // Lấy tin nhắn lỗi từ key 'Message' hoặc 'message' tùy backend
          errorMsg = body['Message'] ?? body['message'] ?? response.body;
        } catch (_) {
          errorMsg =
              response.body; // Nếu server không trả JSON thì lấy text thô
        }
        return {'success': false, 'message': errorMsg};
      }
    } catch (e) {
      // 5. Bắt lỗi kết nối mạng
      return {'success': false, 'message': 'Lỗi kết nối máy chủ: $e'};
    }
  }
}
