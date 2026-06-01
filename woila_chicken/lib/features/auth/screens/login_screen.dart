import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/responsive_layout.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ResponsiveLayout(
        // ── Vue Desktop : deux colonnes ──────────────────────────
        desktop: Row(
          children: [
            Expanded(child: _BrandPanel()),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(40),
                    child: _LoginForm(),
                  ),
                ),
              ),
            ),
          ],
        ),

        // ── Vue Mobile : une colonne ─────────────────────────────
        mobile: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                color: AppColors.primary,
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.5),
                            width: 2.5),
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Center(
                                child:
                                    Icon(Icons.storefront_rounded, color: AppColors.primary, size: 40)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('WOÏLA CHICKEN',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 2)),
                    const SizedBox(height: 4),
                    Text('La ferme à portée de main',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.75))),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: _LoginForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Panneau branding gauche (desktop) ───────────────────────────
class _BrandPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo réel dans un cercle blanc
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.5), width: 3),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 8))
                  ],
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.set_meal_rounded, color: AppColors.primary, size: 64)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              const Text('WOÏLA CHICKEN',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 2.5),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('La ferme à portée de main',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.75))),
              const SizedBox(height: 48),

              _FeatureItem(
                  icon: Icons.verified_outlined,
                  label: 'Produits certifiés et vérifiés'),
              const SizedBox(height: 12),
              _FeatureItem(
                  icon: Icons.local_shipping_outlined,
                  label: 'Livraison ou retrait à la ferme'),
              const SizedBox(height: 12),
              _FeatureItem(
                  icon: Icons.phone_android_outlined,
                  label: 'Paiement sécurisé Mobile Money'),
              const SizedBox(height: 12),
              _FeatureItem(
                  icon: Icons.star_outline,
                  label: 'Fermes notées par la communauté'),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 13, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── Formulaire partagé mobile + desktop ─────────────────────────
class _LoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Bienvenue', style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 6),
        Text('Connectez-vous à votre espace',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 32),
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Adresse email',
            prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Mot de passe',
            prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: const Text('Mot de passe oublié ?',
                style: TextStyle(
                    color: AppColors.primary,
                    fontFamily: 'Poppins',
                    fontSize: 13)),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => Get.toNamed(AppRoutes.roleSelection),
          child: const Text('Se connecter'),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('ou', style: Theme.of(context).textTheme.bodyMedium),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: () {},
          child: const Text('Créer un compte'),
        ),
      ],
    );
  }
}
