class ApiConstants {
  // Thay đổi địa chỉ IP máy tính của bạn tại đây
  static const String ip = '192.168.2.10';
  static const String ip1school = 'localhost';
  // Port của API (Backend chạy port nào thì điền port đó, ví dụ 8476)
  static const String port = '8476';
  static const String portLocalhost = '59269';
  // Base URL dùng chung cho toàn app
  static const String serverUrl = 'http://$ip1school:$portLocalhost';
  static const String baseUrl = 'http://$ip1school:$portLocalhost/api';
}
