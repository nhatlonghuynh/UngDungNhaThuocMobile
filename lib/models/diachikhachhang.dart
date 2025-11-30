class UserAddress {
  int addressID; // ID thực từ API
  String tempId; // Temp ID khi offline / chưa sync API
  String province;
  String district;
  String ward;
  String street;
  bool isDefault;

  UserAddress({
    required this.addressID,
    this.tempId = "",
    required this.province,
    required this.district,
    required this.ward,
    required this.street,
    this.isDefault = false,
  });

  String get fullAddress => "$street, $ward, $district, $province";

  // Convert to/from JSON
  factory UserAddress.fromJson(Map<String, dynamic> json) => UserAddress(
    addressID: json['ID'] ?? json['addressID'] ?? 0,
    province: json['Province'] ?? json['province'] ?? '',
    district: json['District'] ?? json['district'] ?? '',
    ward: json['Ward'] ?? json['ward'] ?? '',
    street: json['Street'] ?? json['street'] ?? '',
    isDefault: json['IsDefault'] ?? json['isDefault'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'ID': addressID,
    'Province': province,
    'District': district,
    'Ward': ward,
    'Street': street,
    'IsDefault': isDefault,
  };
}
