import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/widgets/HistoryOrder/order_history_card.dart';
import 'package:provider/provider.dart';
import 'package:nhathuoc_mobilee/controller/historyordercontroller.dart';
import 'package:nhathuoc_mobilee/screens/history_detail_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Load mặc định tab đầu tiên (ALL)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderHistoryController>().getMyOrders("ALL");
    });
  }

  // Hàm xử lý khi chuyển Tab
  void _onTabChanged(int index) {
    String status = "ALL";
    switch (index) {
      case 0:
        status = "ALL";
        break;
      case 1:
        status = "Chờ xử lý";
        break;
      case 2:
        status = "Đang giao";
        break;
      case 3:
        status = "Đã giao";
        break;
      case 4:
        status = "Đã hủy";
        break;
    }
    // Gọi API lọc theo trạng thái
    context.read<OrderHistoryController>().getMyOrders(status);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          title: const Text(
            "Lịch sử mua hàng",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
          bottom: TabBar(
            isScrollable: true,
            onTap: _onTabChanged,
            labelColor: AppColors.primaryPink,
            unselectedLabelColor: AppColors.textBrown,
            indicatorColor: AppColors.primaryPink,
            tabs: const [
              Tab(text: "Tất cả"),
              Tab(text: "Chờ xử lý"),
              Tab(text: "Đang giao"),
              Tab(text: "Đã giao"),
              Tab(text: "Đã hủy"),
            ],
          ),
        ),
        body: Consumer<OrderHistoryController>(
          builder: (context, controller, child) {
            // 1. Loading
            if (controller.isLoadingList) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryPink),
              );
            }

            // 2. Error
            if (controller.errorList.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 40,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 10),
                    Text(controller.errorList),
                    TextButton(
                      onPressed: () => controller.getMyOrders("ALL"),
                      child: const Text("Thử lại"),
                    ),
                  ],
                ),
              );
            }

            // 3. Empty
            if (controller.orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 80,
                      color: AppColors.neutralGrey.withOpacity(0.3),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Không có đơn hàng nào",
                      style: TextStyle(color: AppColors.neutralGrey),
                    ),
                  ],
                ),
              );
            }

            // 4. List Data
            return ListView.separated(
              padding: const EdgeInsets.all(15),
              itemCount: controller.orders.length,
              separatorBuilder: (_, _) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                final item = controller.orders[index];

                // [DRY] Sử dụng Widget Card đã tách
                return OrderHistoryCard(
                  order: item,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderDetailScreen(orderId: item.maHD),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
