import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/manager/cartmanager.dart';
import 'package:nhathuoc_mobilee/manager/usermanager.dart';
import 'package:nhathuoc_mobilee/models/giohang.dart';
import 'package:nhathuoc_mobilee/models/useraddress.dart';
import 'package:nhathuoc_mobilee/service/orderservice.dart';
import 'package:nhathuoc_mobilee/service/userservice.dart';

class OrderController extends ChangeNotifier {
  final OrderService _orderService = OrderService();
  final UserService _userService = UserService();

  // ---------------------------------------------------------------------------
  // STATE VARIABLES
  // ---------------------------------------------------------------------------
  // UI State
  bool isOrdering = false;
  int deliveryMethod = 0; // 0: Giao tận nơi, 1: Tại quầy
  String paymentMethod = "COD";
  String note = "";
  String addressDisplay =
      UserManager().diaChi ?? ""; // Địa chỉ hiển thị (String)

  // Address State
  List<UserAddress> addresses = [];
  UserAddress? selectedAddress;

  // Reward Points State
  bool usePoints = false;
  int pointsToUse = 0;
  int get maxPoints => UserManager().diemTichLuy;

  // ---------------------------------------------------------------------------
  // COMPUTED (Tính toán tiền)
  // ---------------------------------------------------------------------------
  double getSubtotal(List<GioHang> items) => _orderService.calcSubtotal(items);

  double getShipping() => _orderService.calcShippingFee(deliveryMethod);

  double getPointDiscount() =>
      usePoints ? _orderService.calcPointDiscount(pointsToUse) : 0;

  double getFinalTotal(List<GioHang> items) {
    return _orderService.calcFinalTotal(
      subtotal: getSubtotal(items),
      shipping: getShipping(),
      discount: getPointDiscount(),
    );
  }

  int getEarnedPoints(List<GioHang> items) =>
      _orderService.calcEarnedPoints(getFinalTotal(items));

  // ---------------------------------------------------------------------------
  // ORDER ACTIONS (Đặt hàng)
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> placeOrder(List<GioHang> items) async {
    // Validate
    if (deliveryMethod == 0 &&
        (addressDisplay.isEmpty || addressDisplay == "Chưa chọn địa chỉ")) {
      throw Exception("Vui lòng nhập địa chỉ giao hàng!");
    }

    try {
      isOrdering = true;
      notifyListeners();

      final result = await _orderService.submitOrder(
        items: items,
        note:
            "$note | ĐC: ${deliveryMethod == 0 ? addressDisplay : 'Nhận tại quầy'}",
        pointDiscount: getPointDiscount(),
        paymentMethod: paymentMethod,
        diaChi: addressDisplay,
      );
      return result;
    } finally {
      isOrdering = false;
      notifyListeners();
    }
  }

  Future<void> confirmPayOS(int maHD, int code) async {
    await _orderService.confirmPayment(maHD, code);
  }

  Future<void> clearCart(List<GioHang> items) async {
    for (var item in items) {
      await CartManager().removeFromCart(item.maThuoc);
    }
  }

  // ---------------------------------------------------------------------------
  // ADDRESS MANAGEMENT (Quản lý địa chỉ)
  // ---------------------------------------------------------------------------

  Future<void> loadUserAddresses({required String userId}) async {
    try {
      addresses = await _userService.getAddresses(userId);
      if (addresses.isNotEmpty) {
        selectedAddress = addresses.firstWhere(
          (e) => e.isDefault,
          orElse: () => addresses.first,
        );
      } else {
        selectedAddress = null;
      }
      notifyListeners();
    } catch (e) {
      print("Lỗi tải địa chỉ: $e");
    }
  }

  Future<void> addNewAddress(UserAddress addr, String userId) async {
    await _userService.addAddress(userId, addr);
    await loadUserAddresses(userId: userId);
  }

  Future<void> editAddress(UserAddress addr) async {
    await _userService.updateAddress(addr);
    // Cập nhật lại nếu đang chọn địa chỉ này
    if (selectedAddress?.addressID == addr.addressID) {
      selectedAddress = addr;
    }
    notifyListeners();
  }

  Future<void> deleteAddress(UserAddress addr, String userId) async {
    await _userService.deleteAddress(addr.addressID);
    await loadUserAddresses(userId: userId);
  }

  void setSelectedAddress(UserAddress addr) {
    selectedAddress = addr;
    addressDisplay = addr.fullAddress; // Cập nhật chuỗi hiển thị
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // UI SETTERS
  // ---------------------------------------------------------------------------
  void setDeliveryMethod(int val) {
    deliveryMethod = val;
    notifyListeners();
  }

  void setPaymentMethod(String val) {
    paymentMethod = val;
    notifyListeners();
  }

  void setAddress(String val) {
    addressDisplay = val;
    notifyListeners();
  }

  void setNote(String val) {
    note = val;
  }

  void toggleUsePoints(bool val) {
    usePoints = val;
    if (!val) pointsToUse = 0;
    notifyListeners();
  }

  void setPointsToUse(int val) {
    pointsToUse = (val > maxPoints) ? maxPoints : val;
    notifyListeners();
  }
}
