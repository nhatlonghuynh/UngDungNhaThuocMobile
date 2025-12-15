import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:nhathuoc_mobilee/UI/widgets/Home/home_components.dart';
import 'package:nhathuoc_mobilee/UI/widgets/Home/item_product.dart';
import 'package:nhathuoc_mobilee/UI/widgets/Home/promo_carousel.dart';
import 'package:nhathuoc_mobilee/UI/widgets/Home/main_drawner.dart';
import 'package:nhathuoc_mobilee/controller/home_controller.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/service/productservice.dart';
import 'package:nhathuoc_mobilee/api/productapi.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          HomeController(service: ProductService(repo: ProductRepository())),
      child: Scaffold(
        drawer: MainDrawer(),
        backgroundColor: AppColors.background,
        body: const HomeBody(),
      ),
    );
  }
}

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('Trạng thái voice: $val'),
        onError: (val) => print('Lỗi voice: $val'),
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          localeId: 'vi_VN',
          onResult: (val) {
            setState(() {
              _searchController.text = val.recognizedWords;

              if (val.finalResult) {
                context.read<HomeController>().onSearch(val.recognizedWords);
              }
            });
          },
        );
      }
    } else {
      // Dừng nghe
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomeController>();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // --- 1. AppBar Title (Menu + Tên App) ---
        SliverAppBar(
          pinned: false,
          floating: true,
          snap: true,
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.menu_outlined, color: AppColors.primary),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          title: const Text(
            'Nhà Thuốc',
            style: TextStyle(
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

        // --- 2. Search Bar (Đã tích hợp Voice) ---
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
              border: Border.all(color: AppColors.border.withOpacity(0.6)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppColors.surface.withOpacity(0.9),
                  blurRadius: 6,
                  offset: const Offset(-2, -2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController, // Gán controller
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
                // Đổi hint text khi đang nghe để user biết
                hintText: _isListening
                    ? "Đang nghe bạn nói..."
                    : "Tên, công dụng thuốc ....",
                hintStyle: TextStyle(
                  color: _isListening
                      ? Colors.redAccent
                      : AppColors.textSecondary.withOpacity(0.9),
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),

                // Nút Mic đã được xử lý sự kiện
                suffixIcon: IconButton(
                  onPressed: _listen,
                  icon: Icon(
                    _isListening ? Icons.mic_off : Icons.mic, // Đổi icon
                    color: _isListening
                        ? Colors.red
                        : AppColors.primary, // Đổi màu
                  ),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),

        // --- 3. Header Info ---
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: HomeHeaderSection(),
          ),
        ),

        // --- 4. Banner ---
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: HomeBannerSection(),
          ),
        ),

        // --- 5. Promo Carousel ---
        Builder(
          builder: (context) {
            final controller = context.watch<HomeController>();
            final promos = controller.products
                .where((p) => controller.checkPromo(p))
                .toList();
            if (promos.isEmpty) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }
            return SliverToBoxAdapter(child: PromoCarousel(promos: promos));
          },
        ),

        // --- 6. Title List ---
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
            child: const Text(
              "Danh sách sản phẩm",
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),

        // --- 7. Grid Sản phẩm ---
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
                (ctx, index) =>
                    SanPhamItem(product: controller.products[index]),
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
