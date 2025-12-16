import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/UI/screens/cart_screen.dart';
import 'package:nhathuoc_mobilee/UI/screens/home_screen.dart';
import 'package:nhathuoc_mobilee/UI/screens/profile_screen.dart';
import 'package:nhathuoc_mobilee/UI/screens/reward_screen.dart';
import 'package:nhathuoc_mobilee/controller/authcontroller.dart';
import 'package:nhathuoc_mobilee/controller/categorycontroller.dart';
import 'package:nhathuoc_mobilee/controller/historyordercontroller.dart';
import 'package:nhathuoc_mobilee/controller/home_controller.dart';
import 'package:nhathuoc_mobilee/controller/productcontroller.dart'; // Import controller chi tiết
import 'package:nhathuoc_mobilee/service/productservice.dart';
import 'package:provider/provider.dart';
import 'package:nhathuoc_mobilee/manager/usermanager.dart';
import 'package:nhathuoc_mobilee/locator.dart';

final GlobalKey<MainScreenState> mainScreenKey = GlobalKey<MainScreenState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  await UserManager().loadUser();
  runApp(const PharmacyApp());
}

class PharmacyApp extends StatelessWidget {
  const PharmacyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CategoryController()),
        // Sử dụng locator để inject service chuẩn
        ChangeNotifierProvider(
          create: (_) => HomeController(service: locator<ProductService>()),
        ),
        ChangeNotifierProvider(create: (_) => OrderHistoryController()),
        // THÊM: Đăng ký controller cho màn hình chi tiết
        ChangeNotifierProvider(create: (_) => ProductDetailController()),

        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => UserManager()),
      ],
      child: MaterialApp(
        title: 'Nhà Thuốc Online',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'Inter',
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            surface: AppColors.surface,
            // ignore: deprecated_member_use
            background: AppColors.background,
            error: AppColors.error,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 2,
            ),
          ),
        ),
        initialRoute: '/',
        routes: {'/': (context) => MainScreen(key: mainScreenKey)},
      ),
    );
  }
}

// ... Phần MainScreen giữ nguyên ...
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    const CartScreen(),
    const RewardScreen(),
    const ProfileScreen(),
  ];

  void navigateToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _screens[_selectedIndex], // Giữ trạng thái khi switch tab cần dùng IndexedStack, nhưng tạm thời để nguyên theo code gốc
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.local_pharmacy),
              label: 'Trang Chủ',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage('assets/icons/shopping-cart.png'),
                size: 24,
              ),
              label: 'Giỏ hàng',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('assets/icons/gift.png'), size: 24),
              label: 'Quà tặng',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Tài khoản',
            ),
          ],
        ),
      ),
    );
  }
}
