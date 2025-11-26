class NguoiDung {
  final String maND;
  final String hoTen;
  final String soDT;
  final String? diaChi;
  final String? email;
  final int diemTL;

  NguoiDung({
    required this.maND,
    required this.hoTen,
    required this.soDT,
    this.diaChi,
    this.diemTL = 0,
    this.email,
  });
}
