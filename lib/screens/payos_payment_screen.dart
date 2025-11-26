import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/common/constants/appcolor.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PayOSPaymentScreen extends StatefulWidget {
  final String paymentUrl;
  final String returnUrlScheme; // Ví dụ: "nhathuoc://"

  const PayOSPaymentScreen({
    super.key,
    required this.paymentUrl,
    this.returnUrlScheme = "nhathuoc://payment-result",
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

    // Khởi tạo WebViewController
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => _isLoading = false);
          },
          onNavigationRequest: (NavigationRequest request) {
            // LOGIC QUAN TRỌNG: Bắt link redirect
            if (request.url.startsWith(widget.returnUrlScheme)) {
              final uri = Uri.parse(request.url);
              final status = uri.queryParameters['status'];
              final orderCode = uri.queryParameters['orderCode']; 

              if (status == 'CANCELLED') {
                Navigator.pop(context, {
                  'success': false,
                  'message': 'Đã hủy thanh toán',
                });
              } else {
                // Mặc định coi như thành công hoặc pending
                Navigator.pop(context, {
                  'success': true,
                  'orderCode': orderCode,
                });
              }
              return NavigationDecision.prevent; // Chặn không cho WebView load link này
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thanh toán PayOS", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, {
            'success': false,
            'message': 'Đóng cổng thanh toán',
          }),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) 
            const Center(
              child: CircularProgressIndicator(color: AppColors.primaryPink),
            ),
        ],
      ),
    );
  }
}