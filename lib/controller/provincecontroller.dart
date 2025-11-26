import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/api/locationapi.dart';
import 'package:nhathuoc_mobilee/models/diachi.dart';

class LocationController extends ChangeNotifier {
  final LocationService _service = LocationService();

  // Lists data
  List<Province> provinces = [];
  List<District> districts = [];
  List<Ward> wards = [];

  // Selected Items
  Province? selectedProvince;
  District? selectedDistrict;
  Ward? selectedWard;

  // Loading state (optional)
  bool isLoading = false;

  /// Tải danh sách Tỉnh/Thành
  Future<void> loadProvinces() async {
    isLoading = true;
    notifyListeners();

    provinces = await _service.getProvinces();

    isLoading = false;
    notifyListeners();
  }

  /// Chọn Tỉnh -> Load Huyện, Reset Xã
  void selectProvince(Province province) {
    selectedProvince = province;
    districts = province.districts;

    // Reset cấp dưới
    selectedDistrict = null;
    wards = [];
    selectedWard = null;

    notifyListeners();
  }

  /// Chọn Huyện -> Load Xã
  void selectDistrict(District district) {
    selectedDistrict = district;
    wards = district.wards;

    // Reset cấp dưới
    selectedWard = null;

    notifyListeners();
  }

  /// Chọn Xã
  void selectWard(Ward ward) {
    selectedWard = ward;
    notifyListeners();
  }
}
