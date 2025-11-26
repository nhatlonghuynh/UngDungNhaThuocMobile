import 'dart:convert';
import 'package:nhathuoc_mobilee/api/productapi.dart';
import 'package:nhathuoc_mobilee/models/thuoc.dart';
import 'package:intl/intl.dart';
import 'package:nhathuoc_mobilee/models/thuoc_detail.dart';

class ProductService {
  final ProductRepository _repo = ProductRepository();
  static final NumberFormat _formatter = NumberFormat('#,###', 'vi_VN');

  Future<List<Thuoc>> getProducts() async {
    return await _repo.fetchAllProducts();
  }

  // --- LOGIC TÍNH TOÁN KHUYẾN MÃI (Chuyển từ Widget sang đây) ---

  // 1. Kiểm tra có khuyến mãi không
  bool hasPromotion(Thuoc thuoc) {
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
  double getDiscountedPrice(Thuoc thuoc) {
    if (!hasPromotion(thuoc)) return thuoc.donGia;

    final km = thuoc.khuyenMai!;
    if (km.phanTramKM > 0) {
      return thuoc.donGia * (1 - (km.phanTramKM / 100));
    } else if (km.tienGiam > 0) {
      double price = thuoc.donGia - km.tienGiam;
      return price > 0 ? price : 0;
    }
    return thuoc.donGia;
  }

  // 3. Lấy text hiển thị badge (VD: -10%)
  String getBadgeText(Thuoc thuoc) {
    if (!hasPromotion(thuoc)) return "";
    final km = thuoc.khuyenMai!;

    if (km.phanTramKM > 0) {
      return "-${km.phanTramKM.toInt()}%";
    } else if (km.tienGiam > 0) {
      double val = km.tienGiam;
      if (val >= 1000) return "-${(val / 1000).toInt()}k";
      return "-${_formatter.format(val)}";
    }
    return "";
  }

  // Format tiền tệ
  String formatMoney(double amount) {
    return _formatter.format(amount);
  }

  Future<List<Thuoc>> searchProductByNameOrUse(String keyword) async {
    return await _repo.searchProducts(keyword);
  }

  Future<Map<String, dynamic>> fetchProductDetail(int id) async {
    try {
      final response = await _repo.getDetailRequest(id);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final product = ThuocDetail.fromJson(data);
        return {'success': true, 'data': product};
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'Không tìm thấy sản phẩm'};
      } else {
        return {
          'success': false,
          'message': 'Lỗi máy chủ: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
}
