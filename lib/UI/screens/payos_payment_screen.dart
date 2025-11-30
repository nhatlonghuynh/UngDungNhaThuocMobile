import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PayOSPaymentScreen extends StatefulWidget {
  final String paymentUrl;
  
  // Return URL Scheme chung (nhathuoc://)
  final String appScheme; 

  const PayOSPaymentScreen({
    super.key,
    required this.paymentUrl,
    this.appScheme = "nhathuoc://",
  });

  @override
  State<PayOSPaymentScreen> createState() => _PayOSPaymentScreenState();
}

class _PayOSPaymentScreenState extends State<PayOSPaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          
          // --- LOGIC BẮT LINK QUAN TRỌNG ---
          onNavigationRequest: (NavigationRequest request) {
            // Kiểm tra xem URL có bắt đầu bằng Scheme của App không (nhathuoc://)
            if (request.url.startsWith(widget.appScheme)) {
              
              final uri = Uri.parse(request.url);
              
              // Case 1: Hủy thanh toán (nhathuoc://payment-cancel hoặc status=CANCELLED)
              // Kiểm tra cả đường dẫn lẫn query param để chắc chắn
              bool isCancel = request.url.contains("payment-cancel") || 
                              uri.queryParameters['status'] == 'CANCELLED';

              if (isCancel) {
                Navigator.pop(context, {
                  'success': false,
                  'message': 'Giao dịch đã bị hủy',
                });
              } 
              // Case 2: Thanh toán thành công (nhathuoc://payment-result)
              else {
                // Lấy orderCode nếu có (để log hoặc verify lại nếu cần)
                final orderCode = uri.queryParameters['orderCode'];
                
                Navigator.pop(context, {
                  'success': true,
                  'message': 'Thanh toán thành công',
                  'orderCode': orderCode,
                });
              }
              
              // Chặn WebView load tiếp (vì đây là Deep Link của App)
              return NavigationDecision.prevent;
            }
            
            // Các link khác (https://payos.vn...) cho phép load bình thường
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Cổng thanh toán PayOS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, {'success': false, 'message': 'Đã đóng cổng thanh toán'}),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
        ],
      ),
    );
  }
}