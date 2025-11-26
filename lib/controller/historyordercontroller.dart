import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/manager/usermanager.dart';
import 'package:nhathuoc_mobilee/models/donhang.dart';
import 'package:nhathuoc_mobilee/service/orderservice.dart';

class OrderHistoryController extends ChangeNotifier {
  final OrderService _service = OrderService();

  // ---------------------------------------------------------------------------
  // STATE DANH SÁCH ĐƠN HÀNG
  // ---------------------------------------------------------------------------
  List<OrderSummary> orders = [];
  bool isLoadingList = false;
  String errorList = '';

  // ---------------------------------------------------------------------------
  // STATE CHI TIẾT ĐƠN HÀNG
  // ---------------------------------------------------------------------------
  OrderDetail? currentDetail;
  bool isLoadingDetail = false;
  String errorDetail = '';

  // ---------------------------------------------------------------------------
  // 1. Lấy danh sách đơn hàng
  // ---------------------------------------------------------------------------
  Future<void> getMyOrders(String status) async {
    if (isLoadingList) return; // Tránh gọi API chồng chéo

    isLoadingList = true;
    errorList = '';
    notifyListeners();

    // Kiểm tra User đã login chưa
    String userId = UserManager().userId;
    if (userId.isEmpty) {
      await UserManager().loadUser();
      userId = UserManager().userId;
    }

    if (userId.isEmpty) {
      isLoadingList = false;
      errorList = 'Vui lòng đăng nhập lại';
      notifyListeners();
      return;
    }

    // Gọi Service lấy danh sách
    final result = await _service.fetchOrders(status);

    isLoadingList = false;
    if (result['success']) {
      orders = result['data'];
    } else {
      errorList = result['message'];
      // TODO: Xử lý token hết hạn nếu cần
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // 2. Lấy chi tiết đơn hàng
  // ---------------------------------------------------------------------------
  Future<void> getOrderDetail(int orderId) async {
    isLoadingDetail = true;
    errorDetail = '';
    currentDetail = null;
    notifyListeners();

    final result = await _service.fetchDetail(orderId);

    isLoadingDetail = false;
    if (result['success']) {
      currentDetail = result['data'];
    } else {
      errorDetail = result['message'];
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // 3. Hủy đơn hàng
  // ---------------------------------------------------------------------------
  Future<bool> cancelOrder(int orderId) async {
    final result = await _service.cancelOrder(orderId);

    if (result['success']) {
      // TODO: Nếu muốn reload danh sách, gọi getMyOrders("ALL");
      return true;
    } else {
      errorDetail = result['message'];
      notifyListeners();
      return false;
    }
  }
}
