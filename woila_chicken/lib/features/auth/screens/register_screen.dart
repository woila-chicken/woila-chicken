import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/user_role.dart';
import '../../../core/routes/app_routes.dart';

// ─── OTP SERVICE (intégré directement) ───────────────────────────
class _OtpService {
  static const _serviceId = 'service_od2fc69';
  static const _templateId = 'template_mj286xa';
  static const _publicKey = 'x95tIHhnKqLjuTAqi';

  static String _generateCode() {
    final rand = Random.secure();
    return List.generate(6, (_) => rand.nextInt(10)).join();
  }

  static Future<void> send(String email) async {
    final code = _generateCode();
    final expiry = DateTime.now().add(const Duration(minutes: 10));

    await FirebaseFirestore.instance.collection('otp_codes').doc(email).set({
      'code': code,
      'expiry': Timestamp.fromDate(expiry),
      'verified': false,
    });

    final response = await http.post(
      Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'service_id': _serviceId,
        'template_id': _templateId,
        'user_id': _publicKey,
        'template_params': {
          'to_email': email,
          'otp_code': code,
          'expiry_minutes': '10',
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur envoi: ${response.body}');
    }
  }

  static Future<bool> verify(String email, String code) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('otp_codes')
          .doc(email)
          .get();
      if (!doc.exists) return false;

      final data = doc.data()!;
      final stored = data['code'] as String;
      final expiry = (data['expiry'] as Timestamp).toDate();
      final verified = data['verified'] as bool? ?? false;

      if (verified) return false;
      if (DateTime.now().isAfter(expiry)) return false;
      if (stored != code) return false;

      await FirebaseFirestore.instance
          .collection('otp_codes')
          .doc(email)
          .update({'verified': true});
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> cleanup(String email) async {
    try {
      await FirebaseFirestore.instance
          .collection('otp_codes')
          .doc(email)
          .delete();
    } catch (_) {}
  }
}

// ─── ÉCRAN PRINCIPAL ─────────────────────────────────────────────
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController(text: '+237 ');
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();

  UserRole _selectedRole = UserRole.client;
  bool _isLoading = false;
  bool _otpSent = false;
  String _errorMsg = '';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  // ── Étape 1 — valider le formulaire et envoyer OTP ─────────────
  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });

    try {
      await _OtpService.send(_emailCtrl.text.trim());
      if (!mounted) return;
      setState(() {
        _otpSent = true;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMsg = 'Impossible d\'envoyer le code. Vérifiez votre email.';
      });
    }
  }

  // ── Étape 2 — vérifier OTP et créer le compte ──────────────────
  Future<void> _verifyAndCreate() async {
    if (_otpCtrl.text.trim().length != 6) {
      setState(() => _errorMsg = 'Entrez le code à 6 chiffres');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });

    try {
      final valid = await _OtpService.verify(
        _emailCtrl.text.trim(),
        _otpCtrl.text.trim(),
      );

      if (!valid) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMsg = 'Code incorrect ou expiré. Demandez un nouveau code.';
        });
        return;
      }

      final auth = Get.find<AuthService>();
      final success = await auth.register(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        phone: _phoneCtrl.text.trim(),
        role: _selectedRole,
      );

      if (!mounted) return;

      if (success) {
        await _OtpService.cleanup(_emailCtrl.text.trim());
        switch (auth.userRole.value) {
          case UserRole.admin:
            Get.offAllNamed(AppRoutes.adminHome);
            break;
          case UserRole.eleveur:
            Get.offAllNamed(AppRoutes.eleveurHome);
            break;
          default:
            Get.offAllNamed(AppRoutes.clientHome);
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMsg = auth.errorMessage.value;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMsg = 'Une erreur est survenue. Réessayez.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Créer un compte'),
        leading: _otpSent
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() {
                  _otpSent = false;
                  _otpCtrl.clear();
                  _errorMsg = '';
                }),
              )
            : null,
      ),
      body: ResponsiveLayout(
        desktop: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: _buildContent(),
          ),
        ),
        mobile: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _otpSent ? _buildOtpStep() : _buildFormStep(),
    );
  }

  // ── Étape 1 : formulaire ────────────────────────────────────────
  Widget _buildFormStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Rejoindre Woïla Chicken',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text('Créez votre compte gratuitement',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 28),

          // Rôle
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
                onTap: () => setState(() => _selectedRole = UserRole.client),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _RoleChip(
                label: 'Éleveur',
                icon: Icons.agriculture_rounded,
                isSelected: _selectedRole == UserRole.eleveur,
                onTap: () => setState(() => _selectedRole = UserRole.eleveur),
              ),
            ),
          ]),
          const SizedBox(height: 20),

          _Field(
            ctrl: _nameCtrl,
            label: 'Nom complet',
            hint: 'Ex: Amadou Diallo',
            icon: Icons.person_outline,
            validator: (v) => v!.isEmpty ? 'Nom requis' : null,
          ),
          const SizedBox(height: 14),
          _Field(
            ctrl: _emailCtrl,
            label: 'Email',
            hint: 'vous@exemple.com',
            icon: Icons.email_outlined,
            keyboard: TextInputType.emailAddress,
            validator: (v) => !v!.contains('@') ? 'Email invalide' : null,
          ),
          const SizedBox(height: 14),
          _Field(
            ctrl: _phoneCtrl,
            label: 'Téléphone',
            hint: '+237 6XX XXX XXX',
            icon: Icons.phone_outlined,
            keyboard: TextInputType.phone,
            validator: (v) {
              final digits = v?.replaceAll(RegExp(r'[^\d]'), '') ?? '';
              if (digits.length < 11) {
                return 'Numéro incomplet (ex: +237 6XX XXX XXX)';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          _Field(
            ctrl: _passCtrl,
            label: 'Mot de passe',
            hint: '6 caractères minimum',
            icon: Icons.lock_outline,
            isPassword: true,
            validator: (v) => v!.length < 6 ? 'Minimum 6 caractères' : null,
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

          if (_errorMsg.isNotEmpty) _ErrorBox(message: _errorMsg),

          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _isLoading ? null : _sendOtp,
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14)),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Recevoir le code de vérification',
                    style: TextStyle(
                        fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('Déjà un compte ?',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppColors.textSecondary)),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Se connecter',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600)),
            ),
          ]),
        ],
      ),
    );
  }

  // ── Étape 2 : saisie OTP ────────────────────────────────────────
  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        // Illustration
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: [
            const Icon(Icons.mark_email_unread_outlined,
                color: AppColors.primary, size: 48),
            const SizedBox(height: 12),
            const Text('Code de vérification',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            Text(
              'Un code à 6 chiffres a été envoyé à\n${_emailCtrl.text.trim()}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppColors.textSecondary),
            ),
          ]),
        ),
        const SizedBox(height: 28),

        // Champ OTP
        TextFormField(
          controller: _otpCtrl,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: 10,
              color: AppColors.primary),
          decoration: InputDecoration(
            labelText: 'Code à 6 chiffres',
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (v) {
            // Auto-soumettre quand 6 chiffres saisis
            if (v.length == 6 && !_isLoading) {
              _verifyAndCreate();
            }
          },
        ),
        const SizedBox(height: 20),

        if (_errorMsg.isNotEmpty) _ErrorBox(message: _errorMsg),

        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _isLoading ? null : _verifyAndCreate,
          style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14)),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Text('Créer mon compte',
                  style: TextStyle(
                      fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _isLoading ? null : _sendOtp,
          child: const Text('Renvoyer le code',
              style:
                  TextStyle(fontFamily: 'Poppins', color: AppColors.primary)),
        ),
      ],
    );
  }
}

// ─── WIDGETS RÉUTILISABLES ────────────────────────────────────────
class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Text(message,
          style: const TextStyle(
              fontFamily: 'Poppins', fontSize: 12, color: AppColors.error)),
    );
  }
}

class _Field extends StatefulWidget {
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
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.ctrl,
      keyboardType: widget.keyboard,
      obscureText: widget.isPassword && _obscure,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: Icon(widget.icon, color: AppColors.primary),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 20,
                color:
                    isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.normal,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
