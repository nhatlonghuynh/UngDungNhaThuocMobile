import 'dart:convert';
import 'package:nhathuoc_mobilee/api/orderapi.dart';
import 'package:nhathuoc_mobilee/api/order_history.dart'; // Import thêm repo history
import 'package:nhathuoc_mobilee/manager/usermanager.dart';
import 'package:nhathuoc_mobilee/models/giohang.dart';
import 'package:nhathuoc_mobilee/models/donhang.dart'; // Import model đơn hàng

class OrderService {
  // Khởi tạo cả 2 Repository để giữ nguyên logic gọi API cũ
  final OrderRepository _orderRepo = OrderRepository();
  final OrderHistoryRepository _historyRepo = OrderHistoryRepository();

  // =======================================================================
  // PHẦN 1: LOGIC TÍNH TOÁN (Gộp từ OrderService cũ & PaymentService)
  // =======================================================================

  double calcSubtotal(List<GioHang> items) {
    return items.fold(0, (sum, item) => sum + (item.donGia * item.soLuong));
  }

  double calcShippingFee(int deliveryMethod) {
    // 0: Giao tận nơi (30k), 1: Nhận tại quầy (0đ)
    return deliveryMethod == 0 ? 30000 : 0;
  }

  double calcPointDiscount(int points) => points * 10.0; // 1 điểm = 10đ

  double calcFinalTotal({
    required double subtotal,
    required double shipping,
    required double discount,
  }) {
    double total = subtotal + shipping - discount;
    return total > 0 ? total : 0;
  }

  int calcEarnedPoints(double total) =>
      (total / 10000).floor(); // Logic cũ của bạn là /10000

  // Hàm validate từ PaymentService cũ đưa sang
  bool validateAddress(int deliveryMethod, String address) {
    if (deliveryMethod == 0 && address == "Chưa chọn địa chỉ") return false;
    return true;
  }

  // =======================================================================
  // PHẦN 2: TẠO ĐƠN HÀNG & THANH TOÁN (Từ OrderService cũ)
  // =======================================================================

  Future<Map<String, dynamic>> submitOrder({
    required List<GioHang> items,
    required String note,
    required double pointDiscount,
    required String paymentMethod,
    required String diaChi,
  }) async {
    // ... (Giữ nguyên logic cũ của bạn) ...
    final listSanPhams = items
        .map(
          (item) => {
            "MaSP": item.maThuoc,
            "SoLuong": item.soLuong,
            "GiaThucTe": item.donGia,
          },
        )
        .toList();

    final body = {
      "MaKH": UserManager().userId,
      "GhiChu": note,
      "GiamGiaVoucher": 0,
      "GiamGiaDiem": pointDiscount,
      "SanPhams": listSanPhams,
      "PaymentMethod": paymentMethod,
      "DiaChiNhanHang": diaChi,
    };

    try {
      final response = await _orderRepo.createOrderApi(body);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "CheckoutUrl": data["CheckoutUrl"],
          "MaHD": data["maHD"],
          "payOSOrderCode": data["orderCode"],
        };
      } else {
        throw Exception(data['Message'] ?? "Tạo đơn thất bại");
      }
    } catch (e) {
      throw Exception("Lỗi Service: $e");
    }
  }

  Future<void> confirmPayment(int maHD, int code) async {
    final response = await _orderRepo.confirmPaymentApi(maHD, code);
    if (response.statusCode != 200) {
      throw Exception("Lỗi xác nhận thanh toán");
    }
  }

  // =======================================================================
  // PHẦN 3: LỊCH SỬ & CHI TIẾT ĐƠN HÀNG (Từ HistoryService cũ)
  // =======================================================================

  Future<Map<String, dynamic>> fetchOrders(String status) async {
    try {
      final response = await _historyRepo.getOrderHistory(status);

      if (response.statusCode == 200) {
        final List<dynamic> rawList = jsonDecode(response.body);
        final orders = rawList.map((e) => OrderSummary.fromJson(e)).toList();
        return {'success': true, 'data': orders};
      } else if (response.statusCode == 401) {
        return {'success': false, 'message': 'Phiên đăng nhập hết hạn (401)'};
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'Sai đường dẫn API (404)'};
      } else {
        return {
          'success': false,
          'message': 'Lỗi Server (${response.statusCode})',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi xử lý: $e'};
    }
  }

  Future<Map<String, dynamic>> fetchDetail(int orderId) async {
    try {
      final response = await _historyRepo.getOrderDetail(orderId);
      if (response.statusCode == 200) {
        final rawData = jsonDecode(response.body);
        final detail = OrderDetail.fromJson(rawData);
        return {'success': true, 'data': detail};
      } else {
        return {'success': false, 'message': 'Không tìm thấy đơn hàng'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  Future<Map<String, dynamic>> cancelOrder(int orderId) async {
    try {
      final response = await _historyRepo.cancelOrder(orderId);
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Hủy thành công'};
      } else {
        final body = jsonDecode(response.body);
        return {
          'success': false,
          'message': body['Message'] ?? 'Không thể hủy đơn hàng này',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
}
