import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/UI/widgets/Cart/cart_bottom_bar.dart';
import 'package:nhathuoc_mobilee/UI/widgets/Cart/cart_empty.dart';
import 'package:nhathuoc_mobilee/UI/widgets/Cart/cart_item.dart';
import 'package:provider/provider.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/controller/cartcontroller.dart';
import 'package:nhathuoc_mobilee/controller/authcontroller.dart';
import 'package:nhathuoc_mobilee/manager/usermanager.dart';
import 'package:nhathuoc_mobilee/UI/screens/login_screen.dart';
import 'package:nhathuoc_mobilee/UI/screens/orderscreen.dart';
import 'package:nhathuoc_mobilee/UI/common/utils/dialog_helper.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  CartScreenState createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  final CartController _controller = CartController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    await _controller.loadData();
    if (mounted) setState(() {});
  }

  // Hàm này truyền xuống con để con gọi ngược lên khi cần vẽ lại
  void _refreshUI() {
    if (mounted) setState(() {});
  }

  // Xử lý nút Mua hàng
  void _handleCheckout() async {
    if (!UserManager().isLoggedIn) {
      // [DRY] Tái sử dụng DialogHelper lần nữa cho việc Login
      final bool? shouldLogin = await DialogHelper.showLoginRequirement(
        context,
      );

      if (shouldLogin == true) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
              create: (_) => AuthController(),
              child: const LoginScreen(),
            ),
          ),
        );
      }
    } else {
      // Đã đăng nhập -> Sang màn hình đặt hàng
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderScreen(
            selectedItems: _controller.selectedItems,
            userId: UserManager().userId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text(
          "Giỏ hàng",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryPink,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: _controller.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryPink),
            )
          : Column(
              children: [
                Expanded(
                  // Logic hiển thị danh sách hoặc màn hình trống
                  child: _controller.cartItems.isEmpty
                      ? const CartEmptyWidget()
                      : ListView.separated(
                          padding: const EdgeInsets.all(15),
                          itemCount: _controller.cartItems.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 15),
                          itemBuilder: (context, index) => CartItemWidget(
                            index: index,
                            controller: _controller,
                            onRefresh: _refreshUI, // Truyền hàm refresh
                          ),
                        ),
                ),
                // Thanh thanh toán bên dưới
                CartBottomBar(
                  controller: _controller,
                  onRefresh: _refreshUI,
                  onCheckout: _handleCheckout,
                ),
              ],
            ),
    );
  }
}
