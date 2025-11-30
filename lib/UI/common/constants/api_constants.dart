class ApiConstants {
  // Thay đổi địa chỉ IP máy tính của bạn tại đây
  static const String ipschool = '192.168.2.10';
  static const String ip1school = 'localhost';
  // Port của API (Backend chạy port nào thì điền port đó, ví dụ 8476)
  static const String port = '8476';

  // Base URL dùng chung cho toàn app
  static const String baseUrl = 'http://$ipschool:$port/api';
}
