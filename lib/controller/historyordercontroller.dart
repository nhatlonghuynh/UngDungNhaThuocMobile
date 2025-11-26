import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/manager/usermanager.dart';
import 'package:nhathuoc_mobilee/models/donhang.dart';
import 'package:nhathuoc_mobilee/service/orderservice.dart';

class OrderHistoryController extends ChangeNotifier {
  final OrderService _service = OrderService();

  // ---------------------------------------------------------------------------
  // STATE: LIST ORDER
  // ---------------------------------------------------------------------------
  List<OrderSummary> orders = [];
  bool isLoadingList = false;
  String errorList = '';

  // ---------------------------------------------------------------------------
  // STATE: ORDER DETAIL
  // ---------------------------------------------------------------------------
  OrderDetail? currentDetail;
  bool isLoadingDetail = false;
  String errorDetail = '';

  // ---------------------------------------------------------------------------
  // PUBLIC METHODS
  // ---------------------------------------------------------------------------

  /// Lấy danh sách đơn hàng theo trạng thái
  Future<void> getMyOrders(String status) async {
    if (isLoadingList) return; // Debounce

    // Kiểm tra đăng nhập
    String userId = UserManager().userId;
    if (userId.isEmpty) {
      await UserManager().loadUser();
      userId = UserManager().userId;
    }
    if (userId.isEmpty) {
      errorList = 'Vui lòng đăng nhập lại';
      notifyListeners();
      return;
    }

    try {
      isLoadingList = true;
      errorList = '';
      notifyListeners();

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

  /// Lấy chi tiết đơn hàng
  Future<void> getOrderDetail(int orderId) async {
    try {
      isLoadingDetail = true;
      errorDetail = '';
      currentDetail = null;
      notifyListeners();

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

  /// Hủy đơn hàng
  Future<bool> cancelOrder(int orderId) async {
    try {
      final result = await _service.cancelOrder(orderId);
      if (result['success']) {
        return true;
      } else {
        errorDetail = result['message'];
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
