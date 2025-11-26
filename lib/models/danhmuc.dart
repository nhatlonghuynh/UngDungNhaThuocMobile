class DanhMuc {
  final int id;
  final String ten;
  DanhMuc({required this.id, required this.ten});

  factory DanhMuc.fromJson(Map<String, dynamic> json) {
    return DanhMuc(id: json['Id'] ?? 0, ten: json['Ten'] ?? '');
  }
}

class LoaiDanhMuc {
  final int id;
  final String ten;
  final List<DanhMuc> danhMucCon;

  LoaiDanhMuc({required this.id, required this.ten, required this.danhMucCon});

  factory LoaiDanhMuc.fromJson(Map<String, dynamic> json) {
    var list = json['DanhMucCon'] as List? ?? [];
    List<DanhMuc> children = list.map((i) => DanhMuc.fromJson(i)).toList();
    return LoaiDanhMuc(
      id: json['Id'] ?? 0,
      ten: json['Ten'] ?? '',
      danhMucCon: children,
    );
  }
}
