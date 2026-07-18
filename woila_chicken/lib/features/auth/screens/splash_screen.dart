import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/models/user_role.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/routes/app_routes.dart';
import 'maintenance_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 2000), () async {
  final auth = Get.find<AuthService>();
  final firestore = Get.find<FirestoreService>();

  // Vérifier le mode maintenance
  final isMaintenance = await firestore.isMaintenanceMode();

  if (isMaintenance && !auth.isAdmin.value) {
    // Afficher la page de maintenance
    Get.offAll(() => const MaintenanceScreen());
    return;
  }

  if (auth.isLoggedIn) {
  switch (auth.userRole.value) {
    case UserRole.admin:
      Get.offAllNamed(AppRoutes.adminHome);
      break;
    case UserRole.eleveur:
      Get.offAllNamed(AppRoutes.eleveurHome);
      break;
    case UserRole.client:
    default:
      Get.offAllNamed(AppRoutes.clientHome);
      break;
  }
} else {
    Get.offNamed(AppRoutes.login);
  }
});
  
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        // ConstrainedBox pour que sur desktop ça reste compact et centré
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Logo dans un cercle blanc ──────────────────
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.4),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                            child: Icon(Icons.set_meal_rounded, color: AppColors.primary, size: 64),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Nom ───────────────────────────────────────
                  const Text(
                    'WOÏLA CHICKEN',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  // ── Trait décoratif ────────────────────────────
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          width: 40,
                          height: 1,
                          color: AppColors.accent.withValues(alpha: 0.6)),
                      const SizedBox(width: 12),
                      Text(
                        'La ferme à portée de main',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.75),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                          width: 40,
                          height: 1,
                          color: AppColors.accent.withValues(alpha: 0.6)),
                    ],
                  ),
                  const SizedBox(height: 56),

                  // ── Indicateur de chargement ───────────────────
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accent.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
