import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'features/client/controllers/cart_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(CartController());
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
