import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nhathuoc_mobilee/manager/cartmanager.dart';
import 'package:nhathuoc_mobilee/manager/usermanager.dart';
import 'package:nhathuoc_mobilee/models/diachikhachhang.dart'; // UserAddress
import 'package:nhathuoc_mobilee/models/giohang.dart';
import 'package:nhathuoc_mobilee/service/orderservice.dart';
import 'package:nhathuoc_mobilee/service/useraddress_service.dart';

class OrderController extends ChangeNotifier {
  // --- 1. SERVICES ---
  final OrderService _orderService = OrderService();
  final UserAddressService _addressService = UserAddressService();

  // Key lưu cache (Unique theo UserID)
  final String _storageKey = "cached_addr_${UserManager().userId}";

  // --- 2. STATE VARIABLES ---

  // Trạng thái UI
  bool isOrdering = false;
  int deliveryMethod = 0; // 0: Giao tận nơi, 1: Tại quầy
  String paymentMethod = "COD";
  String note = "";

  // Địa chỉ hiển thị (Gửi lên API)
  String addressDisplay = UserManager().diaChi ?? "";

  // Danh sách địa chỉ (Quản lý Logic UI)
  List<UserAddress> addresses = [];
  UserAddress? selectedAddress;

  // Điểm tích lũy
  bool usePoints = false;
  int pointsToUse = 0;
  int get maxPoints => UserManager().diemTichLuy;

  // --- 3. COMPUTED (Tính toán tiền) ---
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

  // --- 4. ORDER ACTIONS (Đặt hàng) ---

  Future<Map<String, dynamic>> placeOrder(List<GioHang> items) async {
    // --- 1. VALIDATE ĐỊA CHỈ ---
    if (deliveryMethod == 0) {
      // Check 1: Chưa chọn địa chỉ (Dùng object check cho chuẩn)
      if (selectedAddress == null) {
        throw Exception("Vui lòng chọn địa chỉ giao hàng!");
      }

      // Check 2: Địa chỉ đang đồng bộ (ID âm hoặc bằng 0)
      // Đây là lớp bảo vệ cho phần Optimistic UI
      if (selectedAddress!.addressID <= 0) {
        throw Exception(
          "Địa chỉ đang được đồng bộ, vui lòng thử lại sau vài giây!",
        );
      }
    }

    try {
      isOrdering = true;
      notifyListeners();

      // Xác định chuỗi địa chỉ gửi đi
      String finalAddressStr = "Nhận tại nhà thuốc";

      if (deliveryMethod == 0) {
        // Dùng fullAddress từ Model chuẩn hơn dùng biến display
        finalAddressStr = selectedAddress!.fullAddress;
      }

      // --- 2. GỌI SERVICE ---
      final result = await _orderService.submitOrder(
        items: items,
        note: "$note | ĐC: $finalAddressStr",
        pointToUse: getPointDiscount(),
        paymentMethod: paymentMethod,

        // Gửi chuỗi địa chỉ chuẩn
        diaChi: finalAddressStr,

        // [KHUYẾN NGHỊ] Nếu API Order của bạn hỗ trợ nhận AddressID thì truyền thêm vào đây
        // addressId: finalAddressId,
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

  // --- 5. OPTIMISTIC UI: ADDRESS MANAGEMENT ---

  Future<void> loadUserAddresses({required String userId}) async {
    // B1: Load Cache
    await _loadFromSP();

    if (selectedAddress == null && addresses.isNotEmpty) {
      _selectDefaultAddress();
    }
    notifyListeners();

    // B2: Sync API
    try {
      final serverData = await _addressService.getAddresses(userId);
      addresses = serverData;
      await _saveToSP();

      // Chọn lại default để đảm bảo data mới nhất
      if (selectedAddress == null && addresses.isNotEmpty) {
        _selectDefaultAddress();
      }
      notifyListeners();
    } catch (e) {
      debugPrint("⚠️ Lỗi sync server (Dùng cache): $e");
    }
  }

  Future<void> addNewAddress(UserAddress addr, String userId) async {
    // 1. Tạo ID tạm (Số âm để không trùng ID server)
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    final int myTempId = -timestamp; // Ví dụ: -1715482...

    // Tạo object tạm để hiện lên UI ngay
    final newLocalAddr = UserAddress(
      addressID: myTempId,
      province: addr.province,
      district: addr.district,
      ward: addr.ward,
      street: addr.street,
      isDefault: addr.isDefault,
    );

    // 2. CẬP NHẬT UI NGAY (OPTIMISTIC UPDATE)
    addresses.insert(0, newLocalAddr);

    // Xử lý logic chọn mặc định
    if (newLocalAddr.isDefault) {
      for (var item in addresses) {
        if (item != newLocalAddr) item.isDefault = false;
      }
      setSelectedAddress(newLocalAddr);
    }

    notifyListeners();
    try {
      int realId = await _addressService.addAddress(userId, addr);

      if (realId > 0) {
        final index = addresses.indexWhere((e) => e.addressID == myTempId);

        if (index != -1) {
          addresses[index].addressID = realId;
          if (selectedAddress?.addressID == myTempId) {
            selectedAddress = addresses[index];
          }
          await _saveToSP();

          debugPrint("✅ Đã đồng bộ ID thật: $realId");
          notifyListeners();
        }
      } else {
        throw Exception("Server trả về ID không hợp lệ");
      }
    } catch (e) {
      debugPrint("❌ Lỗi sync add: $e");
      addresses.removeWhere((element) => element.addressID == myTempId);

      // Nếu lỡ chọn nó rồi thì reset selectedAddress
      if (selectedAddress?.addressID == myTempId) {
        selectedAddress = addresses.isNotEmpty ? addresses.first : null;
      }

      notifyListeners();
    }
  }

  Future<void> deleteAddress(UserAddress addr, String userId) async {
    final int backupIndex = addresses.indexOf(addr);
    final UserAddress backupItem = addr;

    // Delete UI ngay
    addresses.remove(addr);

    if (selectedAddress?.addressID == addr.addressID) {
      selectedAddress = null;
      addressDisplay = "";
      if (addresses.isNotEmpty) _selectDefaultAddress();
    }

    await _saveToSP();
    notifyListeners();

    // Call API (Chỉ gọi nếu ID dương)
    if (addr.addressID > 0) {
      try {
        await _addressService.deleteAddress(addr.addressID);
      } catch (e) {
        debugPrint("❌ Lỗi xóa server: $e -> Rollback");
        // Rollback nếu lỗi mạng
        if (backupIndex != -1) {
          addresses.insert(backupIndex, backupItem);
          await _saveToSP();
          notifyListeners();
        }
      }
    }
  }

  // --- 6. HELPERS ---

  Future<void> _saveToSP() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String data = jsonEncode(addresses.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, data);
    } catch (e) {
      debugPrint("Lỗi save cache: $e");
    }
  }

  Future<void> _loadFromSP() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_storageKey);
      if (data != null && data.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(data);
        addresses = jsonList.map((e) => UserAddress.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("Lỗi load cache: $e");
    }
  }

  // --- 7. UI SETTERS ---

  void _selectDefaultAddress() {
    selectedAddress = addresses.firstWhere(
      (addr) => addr.isDefault,
      orElse: () => addresses.first,
    );
    addressDisplay = selectedAddress!.fullAddress;
  }

  void setSelectedAddress(UserAddress addr) {
    selectedAddress = addr;
    addressDisplay = addr.fullAddress;
    notifyListeners();
  }

  void setDeliveryMethod(int val) {
    deliveryMethod = val;
    notifyListeners();
  }

  void setPaymentMethod(String val) {
    paymentMethod = val;
    notifyListeners();
  }

  void setNote(String val) => note = val;

  void toggleUsePoints(bool val) {
    usePoints = val;
    if (!val) pointsToUse = 0;
    notifyListeners();
  }

  void setPointsToUse(dynamic val) {
    int value = 0;
    if (val is int) value = val;
    if (val is String) value = int.tryParse(val) ?? 0;
    pointsToUse = (value > maxPoints) ? maxPoints : (value < 0 ? 0 : value);
    notifyListeners();
  }
}
