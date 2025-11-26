import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/manager/cartmanager.dart';
import 'package:nhathuoc_mobilee/manager/usermanager.dart';
import 'package:nhathuoc_mobilee/models/giohang.dart';
import 'package:nhathuoc_mobilee/models/useraddress.dart';
import 'package:nhathuoc_mobilee/service/orderservice.dart';
import 'package:nhathuoc_mobilee/service/userservice.dart';

class OrderController extends ChangeNotifier {
  final OrderService _service = OrderService();
  final UserService _serviceaddress = UserService();

  List<UserAddress> addresses = [];
  UserAddress? selectedAddress;
  // --- STATE (Trạng thái UI) ---
  bool isOrdering = false;
  int deliveryMethod = 0; // 0: Giao tận nơi, 1: Tại quầy
  String paymentMethod = "COD";
  String address = UserManager().diaChi ?? "";
  String note = "";

  // Điểm thưởng
  bool usePoints = false;
  int pointsToUse = 0;
  int get maxPoints => UserManager().diemTichLuy;

  // --- COMPUTED (Tính toán để hiển thị) ---
  double getSubtotal(List<GioHang> items) => _service.calcSubtotal(items);

  double getShipping() => _service.calcShippingFee(deliveryMethod);

  double getPointDiscount() =>
      usePoints ? _service.calcPointDiscount(pointsToUse) : 0;

  double getFinalTotal(List<GioHang> items) {
    return _service.calcFinalTotal(
      subtotal: getSubtotal(items),
      shipping: getShipping(),
      discount: getPointDiscount(),
    );
  }

  int getEarnedPoints(List<GioHang> items) =>
      _service.calcEarnedPoints(getFinalTotal(items));

  // --- ACTIONS (Hành động) ---

  Future<Map<String, dynamic>> placeOrder(List<GioHang> items) async {
    // Validate
    if (deliveryMethod == 0 &&
        (address.isEmpty || address == "Chưa chọn địa chỉ")) {
      throw Exception("Vui lòng nhập địa chỉ giao hàng!");
    }

    isOrdering = true;
    notifyListeners();

    try {
      final result = await _service.submitOrder(
        items: items,
        note: "$note | ĐC: ${deliveryMethod == 0 ? address : 'Nhận tại quầy'}",
        pointDiscount: getPointDiscount(),
        paymentMethod: paymentMethod,
        diaChi: address,
      );
      return result;
    } catch (e) {
      rethrow;
    } finally {
      isOrdering = false;
      notifyListeners();
    }
  }

  Future<void> confirmPayOS(int maHD, int code) async {
    await _service.confirmPayment(maHD, code);
  }

  Future<void> clearCart(List<GioHang> items) async {
    for (var item in items) {
      await CartManager().removeFromCart(item.maThuoc);
    }
  }

  // --- SETTERS (Cập nhật UI) ---
  void setDeliveryMethod(int val) {
    deliveryMethod = val;
    notifyListeners();
  }

  void setPaymentMethod(String val) {
    paymentMethod = val;
    notifyListeners();
  }

  void setAddress(String val) {
    address = val;
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

  Future<void> loadUserAddresses({required String userId}) async {
    addresses = await _serviceaddress.getAddresses(userId);
    if (addresses.isEmpty) {
      selectedAddress =
          null; // nếu selectedAddress là UserAddress?, cho phép null
    } else {
      selectedAddress = addresses.firstWhere(
        (e) => e.isDefault,
        orElse: () => addresses.first,
      );
      notifyListeners();
    }
  }

  void setSelectedAddress(UserAddress addr) {
    selectedAddress = addr;
    notifyListeners();
  }

  Future<void> addNewAddress(UserAddress addr, String userId) async {
    await _serviceaddress.addAddress(userId, addr);
    await loadUserAddresses(userId: userId);
  }

  Future<void> editAddress(UserAddress addr) async {
    await _serviceaddress.updateAddress(addr);
    if (selectedAddress?.addressID == addr.addressID) {
      selectedAddress = addr;
    }
    notifyListeners();
  }

  Future<void> deleteAddress(UserAddress addr, String userId) async {
    await _serviceaddress.deleteAddress(addr.addressID);
    await loadUserAddresses(userId: userId);
  }
}
