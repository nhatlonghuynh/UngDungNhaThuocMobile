class UserAddress {
  final int addressID;
  final String province;
  final String district;
  final String ward;
  final String street;
  final bool isDefault;

  UserAddress({
    required this.addressID,
    required this.province,
    required this.district,
    required this.ward,
    required this.street,
    required this.isDefault,
  });

  String get fullAddress =>
      "$street, $ward, $district, $province";

  factory UserAddress.fromJson(Map<String, dynamic> json) => UserAddress(
        addressID: json['AddressID'],
        province: json['Province'],
        district: json['District'],
        ward: json['Ward'],
        street: json['Street'],
        isDefault: json['IsDefault'],
      );

  Map<String, dynamic> toJson() => {
        "AddressID": addressID,
        "Province": province,
        "District": district,
        "Ward": ward,
        "Street": street,
        "IsDefault": isDefault,
      };
}
