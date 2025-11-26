import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/controller/categorycontroller.dart';
import 'package:nhathuoc_mobilee/controller/historyordercontroller.dart';
import 'package:nhathuoc_mobilee/controller/home_controller.dart';
import 'package:provider/provider.dart'; // Thêm thư viện Provider
import 'package:nhathuoc_mobilee/manager/usermanager.dart';
import 'package:nhathuoc_mobilee/screens/home_screen.dart';
import 'package:nhathuoc_mobilee/screens/profile_screen.dart';
import 'package:nhathuoc_mobilee/screens/cart_screen.dart';
import 'package:nhathuoc_mobilee/screens/reward_screen.dart';
import 'package:nhathuoc_mobilee/common/constants/appcolor.dart';

// 1. Biến toàn cục để điều khiển MainScreen từ xa
final GlobalKey<MainScreenState> mainScreenKey = GlobalKey<MainScreenState>();

// 2. Điểm khởi chạy ứng dụng
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        ChangeNotifierProvider(create: (_) => HomeController()),
        ChangeNotifierProvider(create: (_) => OrderHistoryController()),
      ],
      child: MaterialApp(
        title: 'Nhà Thuốc Online',
        debugShowCheckedModeBanner: false,

        // --- CẤU HÌNH THEME ---
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.scaffoldBackground,

          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryPink,
            primary: AppColors.primaryPink,
            secondary: AppColors.secondaryGreen,
          ),

          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primaryPink,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),

          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: AppColors.textBrown),
            bodyLarge: TextStyle(color: AppColors.textBrown),
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
              color: AppColors.neutralGrey.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,

          selectedItemColor: AppColors.primaryPink,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),

          unselectedItemColor: AppColors.textBrown.withOpacity(0.6),
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
