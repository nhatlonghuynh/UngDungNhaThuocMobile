import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/UI/common/utils/dialog_helper.dart';
import 'package:provider/provider.dart';
import 'package:nhathuoc_mobilee/main.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/service/productservice.dart'; // Import Service
// import 'package:nhathuoc_mobilee/controller/home_controller.dart'; // Removed
import 'package:nhathuoc_mobilee/controller/authcontroller.dart';
import 'package:nhathuoc_mobilee/manager/cartmanager.dart';
import 'package:nhathuoc_mobilee/manager/usermanager.dart';
import 'package:nhathuoc_mobilee/models/giohang.dart';
import 'package:nhathuoc_mobilee/models/thuoc.dart';
import 'package:nhathuoc_mobilee/UI/screens/orderscreen.dart';
import 'package:nhathuoc_mobilee/UI/screens/login_screen.dart';

class ProductBuySheet extends StatefulWidget {
  final Thuoc thuoc;
  final double finalPrice;

  const ProductBuySheet({
    super.key,
    required this.thuoc,
    required this.finalPrice,
  });

  static void show(
    BuildContext context,
    Thuoc thuoc,
    double finalPrice,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductBuySheet(
        thuoc: thuoc,
        finalPrice: finalPrice,
      ),
    );
  }

  @override
  State<ProductBuySheet> createState() => _ProductBuySheetState();
}

class _ProductBuySheetState extends State<ProductBuySheet> {
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    double total = _qty * widget.finalPrice;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 18,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border.all(color: AppColors.border.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 18),
          const Divider(color: AppColors.background, thickness: 1.5),
          const SizedBox(height: 18),
          _buildQuantitySelector(),
          const SizedBox(height: 18),
          // Tổng tiền
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Tạm tính:",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter',
                ),
              ),
              Text(
                '${ProductService.formatMoney(total)}đ',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            widget.thuoc.anhURL,
            width: 86,
            height: 86,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const Icon(
              Icons.broken_image,
              size: 50,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.thuoc.tenThuoc,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                "Đơn vị: ${widget.thuoc.donVi}",
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${ProductService.formatMoney(widget.finalPrice)}đ',
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Số lượng:",
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: AppColors.surface.withOpacity(0.95),
                blurRadius: 6,
                offset: const Offset(-4, -4),
              ),
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 10,
                offset: const Offset(6, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              _qtyBtn(Icons.remove, () {
                if (_qty > 1) setState(() => _qty--);
              }),
              SizedBox(
                width: 48,
                child: Center(
                  child: Text(
                    '$_qty',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
              _qtyBtn(Icons.add, () {
                if (_qty < widget.thuoc.soLuongTon) {
                  setState(() => _qty++);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Đã đạt giới hạn tồn kho")),
                  );
                }
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // Thêm vào giỏ
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              CartManager().addToCart(widget.thuoc.maThuoc, _qty);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Đã thêm $_qty ${widget.thuoc.donVi} vào giỏ!"),
                  backgroundColor: AppColors.secondary,
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: "XEM GIỎ",
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.of(
                        mainScreenKey.currentContext!,
                      ).popUntil((route) => route.isFirst);
                      mainScreenKey.currentState?.navigateToTab(1);
                    },
                  ),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primary, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              "Thêm vào giỏ",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Mua ngay
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              if (!UserManager().isLoggedIn) {
                final bool? shouldLogin =
                    await DialogHelper.showLoginRequirement(context);
                if (shouldLogin == true && context.mounted) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider(
                        create: (_) => AuthController(),
                        child: const LoginScreen(),
                      ),
                    ),
                  );
                }
                return;
              }

              List<GioHang> itemMua = [
                GioHang(
                  maThuoc: widget.thuoc.maThuoc,
                  anhURL: widget.thuoc.anhURL,
                  donGia: widget.finalPrice,
                  tenThuoc: widget.thuoc.tenThuoc,
                  donVi: widget.thuoc.donVi,
                  soLuong: _qty,
                  isSelected: true,
                ),
              ];
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderScreen(
                    selectedItems: itemMua,
                    userId: UserManager().userId,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 8,
              shadowColor: AppColors.primary.withOpacity(0.18),
            ),
            child: const Text(
              "Mua ngay",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
