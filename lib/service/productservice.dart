import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:nhathuoc_mobilee/api/productapi.dart';
import 'package:nhathuoc_mobilee/models/thuoc.dart';
import 'package:nhathuoc_mobilee/models/thuoc_detail.dart';

class ProductService {
  final ProductRepository _repo = ProductRepository();
  static final NumberFormat _formatter = NumberFormat('#,###', 'vi_VN');

  Future<List<Thuoc>> getProducts() async {
    return await _repo.fetchAllProducts();
  }

  Future<List<Thuoc>> searchProductByNameOrUse(String keyword) async {
    return await _repo.searchProducts(keyword);
  }

  Future<Map<String, dynamic>> fetchProductDetail(int id) async {
    try {
      final response = await _repo.getDetailRequest(id);

      if (response.statusCode == 200) {
        // Decode UTF8 quan trọng
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final product = ThuocDetail.fromJson(data);
        return {'success': true, 'data': product};
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'Không tìm thấy sản phẩm'};
      } else {
        return {
          'success': false,
          'message': 'Lỗi server: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // --- LOGIC TÍNH TOÁN DÙNG CHUNG ---

  // 1. Kiểm tra hiệu lực khuyến mãi
  bool hasPromotion(dynamic thuoc) {
    // Chấp nhận cả Model Thuoc và ThuocDetail (Duck typing logic)
    if (thuoc.khuyenMai == null) return false;
    try {
      DateTime now = DateTime.now();
      DateTime start = DateTime.parse(thuoc.khuyenMai!.ngayBD);
      DateTime end = DateTime.parse(thuoc.khuyenMai!.ngayKT);
      return now.isAfter(start) && now.isBefore(end);
    } catch (e) {
      return false;
    }
  }

  // 2. Tính giá sau giảm
  double getDiscountedPrice(dynamic thuoc) {
    // Lấy giá gốc (Thuoc có donGia, ThuocDetail có giaBan - Check null safety)
    double originalPrice = (thuoc is Thuoc)
        ? thuoc.donGia
        : (thuoc as ThuocDetail).giaBan;

    if (!hasPromotion(thuoc)) return originalPrice;

    final km = thuoc.khuyenMai!;
    if (km.phanTramKM > 0) {
      return originalPrice * (1 - (km.phanTramKM / 100));
    } else if (km.tienGiam > 0) {
      double price = originalPrice - km.tienGiam;
      return price > 0 ? price : 0;
    }
    return originalPrice;
  }

  // 3. Format tiền
  String formatMoney(double amount) => _formatter.format(amount);

  // 4. Badge Text
  String getBadgeText(dynamic thuoc) {
    if (!hasPromotion(thuoc)) return "";
    final km = thuoc.khuyenMai!;
    if (km.phanTramKM > 0) return "-${km.phanTramKM.toInt()}%";
    if (km.tienGiam > 0) return "-${(km.tienGiam / 1000).toInt()}k";
    return "";
  }
}
