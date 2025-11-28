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
    addressID: json['addressID'],
    province: json['province'],
    district: json['district'],
    ward: json['ward'],
    street: json['street'],
    isDefault: json['isDefault'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'addressID': addressID,
    'province': province,
    'district': district,
    'ward': ward,
    'street': street,
    'isDefault': isDefault,
  };
}
