import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/UI/widgets/Home/home_components.dart';
import 'package:nhathuoc_mobilee/UI/widgets/Home/item_product.dart';
import 'package:nhathuoc_mobilee/UI/widgets/Home/main_drawner.dart';
import 'package:provider/provider.dart';
import 'package:nhathuoc_mobilee/controller/home_controller.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/service/productservice.dart';
import 'package:nhathuoc_mobilee/api/productapi.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeController(service: ProductService(repo: ProductRepository())),
      child: Scaffold(
        drawer: MainDrawer(), // Widget Drawer đã tách
        backgroundColor: AppColors.background,
        body: const HomeBody(),
      ),
    );
  }
}

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomeController>();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Floating compact welcome AppBar (glass-like)
        SliverAppBar(
          pinned: false,
          floating: true,
          snap: true,
          centerTitle: true,
          title: Text(
            'Nhà Thuốc',
            style: const TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          backgroundColor: AppColors.background.withOpacity(0.95),
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: AppColors.background.withOpacity(0.6),
              // subtle glass gradient
              gradient: LinearGradient(
                colors: [
                  AppColors.background.withOpacity(0.80),
                  Colors.white.withOpacity(0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),

        // Pinned search bar with soft shadow + rounded
        SliverAppBar(
          pinned: true,
          primary: false,
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.background,
          elevation: 0,
          toolbarHeight: 92,
          title: Container(
            height: 54,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.92),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.border.withOpacity(0.6),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
                // subtle top highlight for neumorphism feel
                BoxShadow(
                  color: AppColors.surface.withOpacity(0.9),
                  blurRadius: 6,
                  offset: const Offset(-2, -2),
                ),
              ],
            ),
            child: TextField(
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                context.read<HomeController>().onSearch(value);
              },
              style: const TextStyle(
                fontFamily: 'Inter',
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: "Tên, công dụng thuốc ....",
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.9),
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: Icon(Icons.mic, color: AppColors.primary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),

        // Header (greet + points)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: HomeHeaderSection(),
          ),
        ),

        // Banner
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: HomeBannerSection(),
          ),
        ),

        // Title
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
            child: Text(
              "Sản phẩm nổi bật",
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),

        // Grid sản phẩm
        if (controller.isLoading)
          const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            ),
          )
        else if (controller.errorMessage.isNotEmpty)
          SliverToBoxAdapter(
            child: Center(child: Text(controller.errorMessage)),
          )
        else if (controller.products.isEmpty)
          const SliverToBoxAdapter(
            child: Center(child: Text("Không có sản phẩm nào")),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (ctx, index) => SanPhamItem(thuoc: controller.products[index]),
                childCount: controller.products.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
            ),
          ),
      ],
    );
  }
}
