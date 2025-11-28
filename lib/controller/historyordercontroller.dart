import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/manager/usermanager.dart';
import 'package:nhathuoc_mobilee/models/donhang.dart';
import 'package:nhathuoc_mobilee/service/orderservice.dart';

class OrderHistoryController extends ChangeNotifier {
  final OrderService _service = OrderService();

  // State List
  List<OrderSummary> orders = [];
  bool isLoadingList = false;
  String errorList = '';

  // State Detail
  OrderDetail? currentDetail;
  bool isLoadingDetail = false;
  String errorDetail = '';

  // --- METHODS ---

  Future<void> getMyOrders(String status) async {
    if (isLoadingList) return;

    // Check Login
    String userId = UserManager().userId;
    if (userId.isEmpty) {
      errorList = 'Vui lòng đăng nhập lại';
      notifyListeners();
      return;
    }

    try {
      isLoadingList = true;
      errorList = '';
      notifyListeners();

      debugPrint("🎮 [Controller] Get Orders: $status");
      final result = await _service.fetchOrders(status);

      if (result['success']) {
        orders = result['data'];
      } else {
        errorList = result['message'];
      }
    } catch (e) {
      errorList = "Lỗi kết nối: $e";
    } finally {
      isLoadingList = false;
      notifyListeners();
    }
  }

  Future<void> getOrderDetail(int orderId) async {
    try {
      isLoadingDetail = true;
      errorDetail = '';
      currentDetail = null;
      notifyListeners();

      debugPrint("🎮 [Controller] Get Detail: $orderId");
      final result = await _service.fetchDetail(orderId);

      if (result['success']) {
        currentDetail = result['data'];
      } else {
        errorDetail = result['message'];
      }
    } catch (e) {
      errorDetail = "Lỗi: $e";
    } finally {
      isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<bool> cancelOrder(int orderId) async {
    try {
      debugPrint("🎮 [Controller] Action Cancel: $orderId");
      final result = await _service.cancelOrder(orderId);

      if (result['success']) {
        return true;
      } else {
        errorDetail = result['message']; // Hiển thị lỗi hủy lên UI chi tiết
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorDetail = "Lỗi khi hủy đơn: $e";
      notifyListeners();
      return false;
    }
  }
}
