import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/UI/common/constants/appcolor.dart';
import 'package:nhathuoc_mobilee/UI/screens/cart_screen.dart';
import 'package:nhathuoc_mobilee/UI/screens/home_screen.dart';
import 'package:nhathuoc_mobilee/UI/screens/profile_screen.dart';
import 'package:nhathuoc_mobilee/UI/screens/reward_screen.dart';
import 'package:nhathuoc_mobilee/controller/categorycontroller.dart';
import 'package:nhathuoc_mobilee/controller/historyordercontroller.dart';
import 'package:nhathuoc_mobilee/controller/home_controller.dart';
import 'package:provider/provider.dart'; // Thêm thư viện Provider
import 'package:nhathuoc_mobilee/manager/usermanager.dart';

import 'package:nhathuoc_mobilee/locator.dart';

// 1. Biến toàn cục để điều khiển MainScreen từ xa
final GlobalKey<MainScreenState> mainScreenKey = GlobalKey<MainScreenState>();

// 2. Điểm khởi chạy ứng dụng
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator(); // Khởi tạo Service Locator
  await UserManager().loadUser();
  runApp(const PharmacyApp());
}

class PharmacyApp extends StatelessWidget {
  const PharmacyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 3. Bọc MaterialApp bằng MultiProvider để khắc phục lỗi ProviderNotFoundException
    return MultiProvider(
      providers: [
        // Khởi tạo CategoryController để toàn bộ App có thể dùng
        ChangeNotifierProvider(create: (_) => CategoryController()),
        ChangeNotifierProvider(
          create: (_) => HomeController(service: locator<ProductService>()),
        ),
        ChangeNotifierProvider(create: (_) => OrderHistoryController()),
      ],
      child: MaterialApp(
        title: 'Nhà Thuốc Online',
        debugShowCheckedModeBanner: false,

        // --- CẤU HÌNH THEME ---
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'Inter', // Ensure Inter is used globally

          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            surface: AppColors.surface,
            background: AppColors.background,
            error: AppColors.error,
          ),

          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),

          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: AppColors.textPrimary),
            bodyLarge: TextStyle(color: AppColors.textPrimary),
            titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 2,
            ),
          ),
        ),

        initialRoute: '/',

        // 4. Khai báo routes (Gắn key vào MainScreen)
        routes: {'/': (context) => MainScreen(key: mainScreenKey)},
      ),
    );
  }
}

// 5. Màn hình chính
class MainScreen extends StatefulWidget {
  const MainScreen({super.key}); // Giữ const và super.key bình thường

  @override
  State<MainScreen> createState() => MainScreenState(); // Đổi tên State thành public
}

// Đổi tên từ _MainScreenState -> MainScreenState (bỏ dấu gạch dưới) để public
class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CartScreen(),
    const RewardScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // --- HÀM PUBLIC ĐỂ GỌI TỪ BÊN NGOÀI ---
  void navigateToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],

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
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),

          unselectedItemColor: AppColors.textSecondary,
          unselectedLabelStyle: const TextStyle(fontSize: 12),

          currentIndex: _selectedIndex,
          onTap: _onItemTapped,

          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.local_pharmacy_outlined),
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
