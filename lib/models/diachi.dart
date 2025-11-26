class Province {
  final String name;
  final int code;
  final List<District> districts;
  Province({required this.name, required this.code, required this.districts});
  factory Province.fromJson(Map<String, dynamic> json) {
    var districtList = (json['districts'] as List)
        .map((e) => District.fromJson(e))
        .toList();
    return Province(
      name: json['name'],
      code: json['code'],
      districts: districtList,
    );
  }
}

class District {
  final String name;
  final int code;
  final List<Ward> wards;
  District({required this.name, required this.code, required this.wards});
  factory District.fromJson(Map<String, dynamic> json) {
    var wardList = (json['wards'] as List)
        .map((e) => Ward.fromJson(e))
        .toList();
    return District(name: json['name'], code: json['code'], wards: wardList);
  }
}

class Ward {
  final String name;
  final int code;
  Ward({required this.name, required this.code});
  factory Ward.fromJson(Map<String, dynamic> json) =>
      Ward(name: json['name'], code: json['code']);
}
