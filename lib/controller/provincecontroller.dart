import 'package:nhathuoc_mobilee/api/locationapi.dart';
import 'package:nhathuoc_mobilee/models/diachi.dart';

class LocationController {
  final LocationService service = LocationService();

  List<Province> provinces = [];
  List<District> districts = [];
  List<Ward> wards = [];

  Province? selectedProvince;
  District? selectedDistrict;
  Ward? selectedWard;

  Future<void> loadProvinces() async {
    provinces = await service.getProvinces();
  }

  void selectProvince(Province province) {
    selectedProvince = province;
    districts = province.districts;
    selectedDistrict = null;
    wards = [];
    selectedWard = null;
  }

  void selectDistrict(District district) {
    selectedDistrict = district;
    wards = district.wards;
    selectedWard = null;
  }

  void selectWard(Ward ward) {
    selectedWard = ward;
  }
}
