import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/api/locationapi.dart';
import 'package:nhathuoc_mobilee/models/diachi.dart';

class AddressPickerDialog extends StatefulWidget {
  const AddressPickerDialog({super.key});

  @override
  State<AddressPickerDialog> createState() => _AddressPickerDialogState();
}

class _AddressPickerDialogState extends State<AddressPickerDialog> {
  final LocationRepository _locationService = LocationRepository();

  List<Province> _provinces = [];
  Province? _selectedProvince;
  District? _selectedDistrict;
  Ward? _selectedWard;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  void _loadProvinces() async {
    try {
      final data = await _locationService.getProvinces();
      if (!mounted) return;

      setState(() {
        _provinces = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Chọn địa chỉ",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: _isLoading
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ======= 1. Tỉnh / Thành =======
                  DropdownButtonFormField<Province>(
                    value: _selectedProvince,
                    isExpanded: true,
                    hint: const Text("Tỉnh/Thành phố"),
                    items: _provinces
                        .map(
                          (p) =>
                              DropdownMenuItem(value: p, child: Text(p.name)),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedProvince = val;
                        _selectedDistrict = null;
                        _selectedWard = null;
                      });
                    },
                  ),
                  const SizedBox(height: 10),

                  // ======= 2. Quận / Huyện =======
                  DropdownButtonFormField<District>(
                    value: _selectedDistrict,
                    isExpanded: true,
                    hint: const Text("Quận/Huyện"),
                    items: _selectedProvince == null
                        ? []
                        : _selectedProvince!.districts
                              .map(
                                (d) => DropdownMenuItem(
                                  value: d,
                                  child: Text(d.name),
                                ),
                              )
                              .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedDistrict = val;
                        _selectedWard = null;
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  // ======= 3. Xã / Phường =======
                  DropdownButtonFormField<Ward>(
                    value: _selectedWard,
                    isExpanded: true,
                    hint: const Text("Phường/Xã"),
                    items: (_selectedDistrict == null)
                        ? []
                        : _selectedDistrict!.wards
                              .map(
                                (w) => DropdownMenuItem(
                                  value: w,
                                  child: Text(w.name),
                                ),
                              )
                              .toList(),
                    onChanged: (val) {
                      setState(() => _selectedWard = val);
                    },
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Hủy",
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          onPressed:
              (_selectedProvince != null &&
                  _selectedDistrict != null &&
                  _selectedWard != null)
              ? () {
                  final fullAddress =
                      "${_selectedWard!.name}, ${_selectedDistrict!.name}, ${_selectedProvince!.name}";
                  Navigator.pop(context, fullAddress);
                }
              : null,
          child: const Text("Xác nhận", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
