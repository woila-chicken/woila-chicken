import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/user_role.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/responsive_layout.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final isAdmin = args?['isAdmin'] ?? false;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ResponsiveLayout(
        // ── Desktop : panneau gauche branding + droite cartes ──
        desktop: Row(
          children: [
            // Panneau gauche bordeaux (même que login)
            SizedBox(
              width: 360,
              child: Container(
                color: AppColors.primary,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.accent.withValues(alpha: 0.5),
                                  width: 2),
                            ),
                            child: ClipOval(
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Center(
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Center(
                                        child: Center(
                                            child: Icon(
                                                Icons.storefront_rounded,
                                                color: AppColors.primary,
                                                size: 40))),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Center(
                          child: Text(
                            'WOÏLA CHICKEN',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          'Choisissez votre profil pour accéder à votre espace personnalisé.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const _InfoLine(
                            icon: Icons.person_outline,
                            text: 'Client — achetez en toute confiance'),
                        const SizedBox(height: 12),
                        const _InfoLine(
                            icon: Icons.agriculture_outlined,
                            text: 'Éleveur — gérez votre activité'),
                        const SizedBox(height: 12),
                        const _InfoLine(
                            icon: Icons.admin_panel_settings_outlined,
                            text: 'Admin — supervisez le réseau'),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Panneau droit — cartes de rôle centrées
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Qui êtes-vous ?',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Votre expérience sera adaptée à votre rôle',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 36),
                        _RoleCard(
                          icon: Icons.shopping_cart_rounded,
                          role: UserRole.client,
                          color: AppColors.clientColor,
                          onTap: () => Get.offAllNamed(AppRoutes.clientHome),
                        ),
                        const SizedBox(height: 12),
                        _RoleCard(
                          icon: Icons.agriculture_rounded,
                          role: UserRole.eleveur,
                          color: AppColors.eleveurColor,
                          onTap: () => Get.offAllNamed(AppRoutes.eleveurHome),
                        ),
                        const SizedBox(height: 12),
                        if (isAdmin)
  _RoleCard(
    icon: Icons.analytics_rounded,
    role: UserRole.admin,
    color: AppColors.adminColor,
    onTap: () => Get.offAllNamed(AppRoutes.adminHome),
  ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // ── Mobile : classique ─────────────────────────────────
        mobile: Scaffold(
          appBar: AppBar(
            title: const Text('Qui êtes-vous ?'),
            automaticallyImplyLeading: false,
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Choisissez votre profil',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Votre expérience sera adaptée à votre rôle',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _RoleCard(
                  icon: Icons.shopping_cart_rounded,
                  role: UserRole.client,
                  color: AppColors.clientColor,
                  onTap: () => Get.offAllNamed(AppRoutes.clientHome),
                ),
                _RoleCard(
                  icon: Icons.agriculture_rounded,
                  role: UserRole.eleveur,
                  color: AppColors.eleveurColor,
                  onTap: () => Get.offAllNamed(AppRoutes.eleveurHome),
                ),
                if (isAdmin)
  _RoleCard(
    icon: Icons.analytics_rounded,
    role: UserRole.admin,
    color: AppColors.adminColor,
    onTap: () => Get.offAllNamed(AppRoutes.adminHome),
  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accent, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final UserRole role;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.role,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Icon(icon, size: 28, color: color),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.label,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}
