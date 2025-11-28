import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/UI/common/utils/dialog_helper.dart';
import 'package:nhathuoc_mobilee/controller/cartcontroller.dart';
import 'package:nhathuoc_mobilee/controller/authcontroller.dart';
import 'package:nhathuoc_mobilee/manager/usermanager.dart';
import 'package:nhathuoc_mobilee/UI/screens/login_screen.dart';
import 'package:nhathuoc_mobilee/UI/screens/orderscreen.dart';

// Import Widget con (Giả sử bạn đã tách file)
import 'package:nhathuoc_mobilee/UI/widgets/Cart/cart_bottom_bar.dart';
import 'package:nhathuoc_mobilee/UI/widgets/Cart/cart_empty.dart';
import 'package:nhathuoc_mobilee/UI/widgets/Cart/cart_item.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Gọi Singleton Controller
  final CartController _controller = CartController();

  @override
  void initState() {
    super.initState();
    // Load data khi vào màn hình
    _controller.loadData();
  }

  // Hàm xử lý Checkout
  void _handleCheckout() async {
    // Logic kiểm tra đăng nhập giữ nguyên
    if (!UserManager().isLoggedIn) {
      final bool? shouldLogin = await DialogHelper.showLoginRequirement(
        context,
      );
      if (shouldLogin == true && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(
              create: (_) => AuthController(),
              child: const LoginScreen(),
            ),
          ),
        ).then((_) {
          // Khi quay lại từ login, check lại xem user đã login chưa để refresh giỏ nếu cần
          if (UserManager().isLoggedIn) setState(() {});
        });
      }
    } else {
      if (_controller.selectedItems.isEmpty) {
        DialogHelper.showError(
          context,
          message: "Vui lòng chọn sản phẩm để mua",
        );
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrderScreen(
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

      // QUAN TRỌNG: Dùng ListenableBuilder thay vì setState thủ công
      body: ListenableBuilder(
        listenable: _controller, // Lắng nghe Singleton Controller
        builder: (context, child) {
          if (_controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryPink),
            );
          }

          if (_controller.cartItems.isEmpty) {
            return const CartEmptyWidget();
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(15),
                  itemCount: _controller.cartItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 15),
                  itemBuilder: (context, index) {
                    // Truyền index và controller vào Item Widget
                    // ItemWidget KHÔNG CẦN callback onRefresh nữa
                    // Vì khi nó gọi controller.updateQuantity -> notifyListeners -> ListenableBuilder tự vẽ lại
                    return CartItemWidget(
                      index: index,
                      controller: _controller,
                    );
                  },
                ),
              ),

              // Bottom Bar cũng tự cập nhật tổng tiền
              CartBottomBar(
                controller: _controller,
                onCheckout: _handleCheckout,
              ),
            ],
          );
        },
      ),
    );
  }
}
