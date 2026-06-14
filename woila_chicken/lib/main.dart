import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'core/services/firebase_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/firestore_service.dart';
import 'core/services/notification_service.dart';
import 'features/client/controllers/cart_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.init();
  Get.put(AuthService(), permanent: true);
  Get.put(FirestoreService(), permanent: true);
  Get.put(NotificationService(), permanent: true);
  Get.put(CartController(), permanent: true);
  runApp(const WoilaChickenApp());
}

class WoilaChickenApp extends StatelessWidget {
  const WoilaChickenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Woïla Chicken',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.pages,
    );
  }
}