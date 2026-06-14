import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/user_role.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/responsive_layout.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  UserRole _selectedRole = UserRole.client;

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Créer un compte')),
      body: ResponsiveLayout(
        desktop: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: _buildForm(auth),
          ),
        ),
        mobile: _buildForm(auth),
      ),
    );
  }

  Widget _buildForm(AuthService auth) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Rejoindre Woïla Chicken',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text('Créez votre compte gratuitement',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 28),

            // Choix du rôle
            const Text('Je suis...',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: _RoleChip(
                  label: 'Client',
                  icon: Icons.shopping_cart_rounded,
                  isSelected: _selectedRole == UserRole.client,
                  onTap: () => setState(
                      () => _selectedRole = UserRole.client),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _RoleChip(
                  label: 'Éleveur',
                  icon: Icons.agriculture_rounded,
                  isSelected: _selectedRole == UserRole.eleveur,
                  onTap: () => setState(
                      () => _selectedRole = UserRole.eleveur),
                ),
              ),
            ]),
            const SizedBox(height: 20),

            _Field(
              ctrl: _nameCtrl,
              label: 'Nom complet',
              hint: 'Ex: Amadou Diallo',
              icon: Icons.person_outline,
              validator: (v) =>
                  v!.isEmpty ? 'Nom requis' : null,
            ),
            const SizedBox(height: 14),
            _Field(
              ctrl: _emailCtrl,
              label: 'Email',
              hint: 'vous@exemple.com',
              icon: Icons.email_outlined,
              keyboard: TextInputType.emailAddress,
              validator: (v) =>
                  !v!.contains('@') ? 'Email invalide' : null,
            ),
            const SizedBox(height: 14),
            _Field(
              ctrl: _phoneCtrl,
              label: 'Téléphone',
              hint: '+237 6XX XXX XXX',
              icon: Icons.phone_outlined,
              keyboard: TextInputType.phone,
              validator: (v) =>
                  v!.isEmpty ? 'Téléphone requis' : null,
            ),
            const SizedBox(height: 14),
            _Field(
              ctrl: _passCtrl,
              label: 'Mot de passe',
              hint: '6 caractères minimum',
              icon: Icons.lock_outline,
              isPassword: true,
              validator: (v) => v!.length < 6
                  ? 'Minimum 6 caractères'
                  : null,
            ),
            const SizedBox(height: 14),
            _Field(
              ctrl: _confirmCtrl,
              label: 'Confirmer le mot de passe',
              hint: 'Répétez le mot de passe',
              icon: Icons.lock_outline,
              isPassword: true,
              validator: (v) => v != _passCtrl.text
                  ? 'Les mots de passe ne correspondent pas'
                  : null,
            ),
            const SizedBox(height: 16),

            // Erreur
            Obx(() => auth.errorMessage.value.isNotEmpty
                ? Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color:
                              AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Text(auth.errorMessage.value,
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: AppColors.error)),
                  )
                : const SizedBox.shrink()),

            Obx(() => ElevatedButton(
                  onPressed: auth.isLoading.value
                      ? null
                      : () async {
                          if (!_formKey.currentState!
                              .validate()) {
                            return;
                          }
                          auth.errorMessage.value = '';

                          final success = await auth.register(
                            name: _nameCtrl.text.trim(),
                            email: _emailCtrl.text.trim(),
                            password: _passCtrl.text,
                            phone: _phoneCtrl.text.trim(),
                            role: _selectedRole,
                          );

                          if (success) {
                            Get.offAllNamed('/role-selection',
                                arguments: {'isAdmin': false});
                          }
                        },
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14)),
                  child: auth.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white),
                        )
                      : const Text('Créer mon compte',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600)),
                )),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboard;
  final bool isPassword;
  final String? Function(String?)? validator;

  const _Field({
    required this.ctrl,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboard,
    this.isPassword = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      obscureText: isPassword,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 20,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.normal,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}