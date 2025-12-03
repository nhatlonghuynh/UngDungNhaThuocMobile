import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:nhathuoc_mobilee/api/orderapi.dart';
import 'package:nhathuoc_mobilee/api/order_history.dart';
import 'package:nhathuoc_mobilee/manager/usermanager.dart';
import 'package:nhathuoc_mobilee/models/giohang.dart';
import 'package:nhathuoc_mobilee/models/donhang.dart';

class OrderService {
  final OrderRepository _orderRepo = OrderRepository();
  final OrderHistoryRepository _historyRepo = OrderHistoryRepository();

  // --- LOGIC TÍNH TOÁN (Giữ nguyên) ---
  double calcSubtotal(List<GioHang> items) {
    if (items.isEmpty) return 0;
    return items.fold(0, (sum, item) => sum + (item.donGia * item.soLuong));
  }

  double calcShippingFee(int deliveryMethod) => deliveryMethod == 0 ? 30000 : 0;
  double calcPointDiscount(int points) => points * 10.0;

  double calcFinalTotal({
    required double subtotal,
    required double shipping,
    required double discount,
  }) {
    double total = subtotal + shipping - discount;
    return total > 0 ? total : 0;
  }

  int calcEarnedPoints(double total) =>
      (total > 0) ? (total / 1000).floor() : 0;

  // --- LOGIC TẠO ĐƠN ---
  Future<Map<String, dynamic>> submitOrder({
    required List<GioHang> items,
    required String note,
    required double pointToUse,
    required String paymentMethod,
    required String diaChi,
  }) async {
    try {
      debugPrint("🛒 [OrderService] Creating Order...");

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
        "DiemSuDung": pointToUse,
        "SanPhams": listSanPhams,
        "PaymentMethod": paymentMethod,
        "DiaChiNhanHang": diaChi,
      };

      final response = await _orderRepo.createOrderApi(body);
      debugPrint("⬅️ [Create] Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        debugPrint("✅ [Create] Body: ${response.body}");
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "CheckoutUrl": data["CheckoutUrl"],
          "MaHD": data["maHD"],
          "payOSOrderCode": data["orderCode"],
        };
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['Message'] ?? "Tạo đơn thất bại");
      }
    } catch (e) {
      debugPrint("❌ [Create] Error: $e");
      rethrow;
    }
  }

  Future<void> confirmPayment(int maHD, int code) async {
    // ... (Giữ nguyên logic cũ hoặc thêm log tương tự)
    final response = await _orderRepo.confirmPaymentApi(maHD, code);
    if (response.statusCode != 200) throw Exception("Lỗi xác nhận thanh toán");
  }

  // --- LOGIC LỊCH SỬ (HISTORY) ---

  Future<Map<String, dynamic>> fetchOrders(String status) async {
    try {
      debugPrint("📜 [History] Fetching: $status");
      final response = await _historyRepo.getOrderHistory(status);

      debugPrint("⬅️ [History] Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> rawList = jsonDecode(response.body);
        debugPrint("✅ [History] Found ${rawList.length} orders");

        final orders = rawList.map((e) => OrderSummary.fromJson(e)).toList();
        return {'success': true, 'data': orders};
      } else {
        debugPrint("❌ [History] Fail Body: ${response.body}");
        return {
          'success': false,
          'message': 'Lỗi server (${response.statusCode})',
        };
      }
    } catch (e) {
      debugPrint("❌ [History] Exception: $e");
      return {'success': false, 'message': 'Lỗi xử lý: $e'};
    }
  }

  Future<Map<String, dynamic>> fetchDetail(int orderId) async {
    try {
      debugPrint("📄 [Detail] Fetching ID: $orderId");
      final response = await _historyRepo.getOrderDetail(orderId);

      if (response.statusCode == 200) {
        final rawData = jsonDecode(response.body);
        final detail = OrderDetail.fromJson(rawData);
        return {'success': true, 'data': detail};
      } else {
        return {'success': false, 'message': 'Không tìm thấy đơn hàng'};
      }
    } catch (e) {
      debugPrint("❌ [Detail] Error: $e");
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  Future<Map<String, dynamic>> cancelOrder(int orderId) async {
    try {
      debugPrint("🚫 [Cancel] Request ID: $orderId");
      final response = await _historyRepo.cancelOrder(orderId);

      if (response.statusCode == 200) {
        debugPrint("✅ [Cancel] Success");
        return {'success': true, 'message': 'Hủy thành công'};
      } else {
        final body = jsonDecode(response.body);
        debugPrint("❌ [Cancel] Fail: ${body['Message']}");
        return {
          'success': false,
          'message': body['Message'] ?? 'Không thể hủy đơn hàng này',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  //xác nhận nhận hàng
  Future<Map<String, dynamic>> confirmOrderReceived(int orderId) async {
    try {
      debugPrint("📦 [Service] Confirm Received ID: $orderId");
      final response = await _historyRepo.confirmReceivedOrder(orderId);

      if (response.statusCode == 200) {
        debugPrint("✅ [Confirm] Success");
        // Backend trả về: { Message, MaHD, TrangThai, DiemTichLuyHienTai }
        // Bạn có thể parse data này để update UI nếu cần
        return {'success': true, 'message': 'Xác nhận thành công'};
      } else {
        final body = jsonDecode(response.body);
        debugPrint("❌ [Confirm] Fail: ${body['Message']}");
        return {
          'success': false,
          'message': body['Message'] ?? 'Lỗi xác nhận đơn hàng',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
}
