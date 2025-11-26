class ApiConstants {
  // Thay đổi địa chỉ IP máy tính của bạn tại đây
  static const String ip = '192.168.2.9';

  // Port của API (Backend chạy port nào thì điền port đó, ví dụ 8476)
  static const String port = '8476';

  // Base URL dùng chung cho toàn app
  static const String baseUrl = 'http://$ip:$port/api';

  // Base URL cho hình ảnh (nếu cần)
  static const String imageBaseUrl = 'http://$ip:$port/images';
}
