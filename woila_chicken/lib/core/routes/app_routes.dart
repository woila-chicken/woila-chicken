import 'package:get/get.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/role_selection_screen.dart';
import '../../features/client/screens/checkout_screen.dart';
import '../../features/client/screens/client_home_screen.dart';
import '../../features/client/screens/catalogue_screen.dart';
import '../../features/eleveur/screens/eleveur_home_screen.dart';
import '../../features/admin/screens/admin_home_screen.dart';
import '../../features/client/screens/order_tracking_screen.dart';
import '../../features/auth/screens/register_screen.dart';

class AppRoutes {
  static const splash        = '/';
  static const login         = '/login';
  static const register      = '/register';
  static const roleSelection = '/role-selection';

  // Client
  static const clientHome    = '/client/home';
  static const catalogue     = '/client/catalogue';
  static const productDetail = '/client/product-detail';
  static const checkout      = '/client/checkout';
  static const orderTracking = '/client/order-tracking';

  // Éleveur
  static const eleveurHome     = '/eleveur/home';
  static const stockManagement = '/eleveur/stock';
  static const eleveurOrders   = '/eleveur/orders';
  static const farmProfile     = '/eleveur/profile';

  // Admin
  static const adminHome     = '/admin/home';
  static const farmDirectory = '/admin/farms';
  static const disputes      = '/admin/disputes';
  static const statistics    = '/admin/statistics';

  static final pages = [
    GetPage(name: splash,        page: () => const SplashScreen()),
    GetPage(name: login,         page: () => const LoginScreen()),
    GetPage(name: roleSelection, page: () => const RoleSelectionScreen(),
        transition: Transition.fadeIn),
    GetPage(name: clientHome,   page: () => const ClientHomeScreen(),
        transition: Transition.rightToLeft),
    GetPage(name: catalogue,    page: () => const CatalogueScreen(),
        transition: Transition.rightToLeft),
    GetPage(
  name: AppRoutes.checkout,
  page: () => CheckoutScreen(
    product: Get.arguments['product'],
    quantity: Get.arguments['quantity'],
    wantsDelivery: Get.arguments['wantsDelivery'],
  ),
),
GetPage(
  name: AppRoutes.orderTracking,
  page: () => OrderTrackingScreen(orderId: Get.arguments['orderId']),
),
    GetPage(name: eleveurHome,  page: () => const EleveurHomeScreen(),
        transition: Transition.rightToLeft),
    GetPage(name: adminHome,    page: () => const AdminHomeScreen(),
        transition: Transition.rightToLeft),
    GetPage(
  name: AppRoutes.register,
  page: () => const RegisterScreen(),
  transition: Transition.rightToLeft,
),
  ];
}
