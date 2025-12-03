import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/api/locationapi.dart';
import 'package:nhathuoc_mobilee/models/diachi.dart';

class LocationController extends ChangeNotifier {
  final LocationRepository _repo = LocationRepository();

  // Lists data
  List<Province> provinces = [];
  List<District> districts = [];
  List<Ward> wards = [];

  // Selected Items
  Province? selectedProvince;
  District? selectedDistrict;
  Ward? selectedWard;

  bool isLoading = false;

  /// Tải danh sách Tỉnh/Thành
  Future<void> loadProvinces() async {
    if (provinces.isNotEmpty) return; // Cache: Đã có thì không load lại

    isLoading = true;
    notifyListeners();

    provinces = await _repo.getProvinces();

    isLoading = false;
    notifyListeners();
  }

  /// Chọn Tỉnh -> Load Huyện, Reset Xã
  void selectProvince(Province? province) {
    if (province == null) return;

    debugPrint("📍 [Controller] Chọn Tỉnh: ${province.name}");
    selectedProvince = province;
    districts = province.districts;

    // Reset cấp dưới
    selectedDistrict = null;
    wards = [];
    selectedWard = null;

    notifyListeners();
  }

  /// Chọn Huyện -> Load Xã
  void selectDistrict(District? district) {
    if (district == null) return;

    debugPrint("📍 [Controller] Chọn Huyện: ${district.name}");
    selectedDistrict = district;
    wards = district.wards;

    // Reset cấp dưới
    selectedWard = null;

    notifyListeners();
  }

  /// Chọn Xã
  void selectWard(Ward? ward) {
    if (ward == null) return;

    debugPrint("📍 [Controller] Chọn Xã: ${ward.name}");
    selectedWard = ward;
    notifyListeners();
  }

  // Hàm reset chọn lại từ đầu (nếu cần)
  void resetSelection() {
    selectedProvince = null;
    selectedDistrict = null;
    selectedWard = null;
    districts = [];
    wards = [];
    notifyListeners();
  }
}
