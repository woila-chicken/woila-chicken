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
                                  color:
                                      AppColors.accent.withValues(alpha: 0.5),
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

        // Cards groupées sans espace
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _RoleCard(
                icon: Icons.shopping_cart_rounded,
                role: UserRole.client,
                color: AppColors.clientColor,
                onTap: () =>
                    Get.offAllNamed(AppRoutes.clientHome),
                isFirst: true,
                isLast: !isAdmin,
              ),
              Container(height: 0.5, color: AppColors.divider),
              _RoleCard(
                icon: Icons.agriculture_rounded,
                role: UserRole.eleveur,
                color: AppColors.eleveurColor,
                onTap: () =>
                    Get.offAllNamed(AppRoutes.eleveurHome),
                isFirst: false,
                isLast: !isAdmin,
              ),
              if (isAdmin) ...[
                Container(height: 0.5, color: AppColors.divider),
                _RoleCard(
                  icon: Icons.analytics_rounded,
                  role: UserRole.admin,
                  color: AppColors.adminColor,
                  onTap: () =>
                      Get.offAllNamed(AppRoutes.adminHome),
                  isFirst: false,
                  isLast: true,
                ),
              ],
            ],
          ),
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
  final bool isFirst;
  final bool isLast;

  const _RoleCard({
    required this.icon,
    required this.role,
    required this.color,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  String get _label {
    switch (role) {
      case UserRole.client:  return 'Je suis client';
      case UserRole.eleveur: return 'Je suis éleveur';
      case UserRole.admin:   return 'Administration';
    }
  }

  String get _sublabel {
    switch (role) {
      case UserRole.client:  return 'Acheter des produits';
      case UserRole.eleveur: return 'Vendre mes produits';
      case UserRole.admin:   return 'Gérer la plateforme';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(15) : Radius.zero,
        bottom: isLast ? const Radius.circular(15) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 18),
        child: Row(children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_label,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(_sublabel,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.textSecondary)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: color.withValues(alpha: 0.5), size: 20),
        ]),
      ),
    );
  }
}