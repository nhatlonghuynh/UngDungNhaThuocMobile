import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nhathuoc_mobilee/UI/common/constants/api_constants.dart';
import 'package:nhathuoc_mobilee/models/thuoc.dart';

class CartRepository {
  /// =========================================================
  /// Hàm: getProductsByIds
  /// Tác dụng: Gửi danh sách các ID thuốc lên Server để lấy về thông tin chi tiết.
  /// Thường dùng cho chức năng: Hiển thị Giỏ hàng hoặc Danh sách yêu thích.
  /// =========================================================
  Future<List<Thuoc>> getProductsByIds(List<int> ids) async {
    // 1. Kiểm tra đầu vào: Nếu danh sách ID rỗng thì trả về mảng rỗng ngay, đỡ tốn công gọi API
    if (ids.isEmpty) return [];

    try {
      // 2. Tạo đường dẫn API
      final url = Uri.parse('${ApiConstants.baseUrl}/thuoc/get_cart');

      // 3. Gọi POST request lên Server
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"ids": ids}), // Đóng gói list ID thành JSON
      );

      // 4. Xử lý kết quả trả về
      if (response.statusCode == 200) {
        // Parse JSON thành List object Thuoc
        List<dynamic> rawList = jsonDecode(response.body);
        return rawList.map((json) => Thuoc.fromJson(json)).toList();
      } else {
        // Ném lỗi nếu Server trả về mã lỗi (404, 500...)
        throw Exception("Lỗi Server: ${response.statusCode}");
      }
    } catch (e) {
      // 5. Bắt lỗi kết nối (mất mạng, sai IP...) và ném ra ngoài cho Controller xử lý
      rethrow;
    }
  }
}
