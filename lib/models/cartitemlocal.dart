class CartItemLocal {
  final int maThuoc;
  int soLuong;

  CartItemLocal({required this.maThuoc, required this.soLuong});

  // Chuyển thành JSON để lưu xuống máy
  Map<String, dynamic> toJson() {
    return {'maThuoc': maThuoc, 'soLuong': soLuong};
  }

  // Đọc từ JSON của máy lên
  factory CartItemLocal.fromJson(Map<String, dynamic> json) {
    return CartItemLocal(maThuoc: json['maThuoc'], soLuong: json['soLuong']);
  }
}
