import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/routes/app_routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;

  final _nameCtrl =
      TextEditingController(text: 'Amadou Diallo');
  final _phoneCtrl =
      TextEditingController(text: '+237 6XX XXX XXX');
  final _emailCtrl =
      TextEditingController(text: 'amadou@email.com');
  final _quartierCtrl =
      TextEditingController(text: 'Marché central, Garoua');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mon profil'),
        actions: [
          TextButton(
            onPressed: () => setState(() => _isEditing = !_isEditing),
            child: Text(
              _isEditing ? 'Enregistrer' : 'Modifier',
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: ResponsiveLayout(
        desktop: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: _buildContent(),
          ),
        ),
        mobile: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // Avatar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: const Center(
                    child: Icon(Icons.person,
                        size: 44, color: AppColors.primary),
                  ),
                ),
                if (_isEditing)
                  Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt,
                        size: 14, color: Color(0xFF412402)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _nameCtrl.text,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              _emailCtrl.text,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.75)),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // Infos personnelles
        _ProfileCard(
          title: 'Informations personnelles',
          icon: Icons.person_outline,
          child: Column(children: [
            _ProfileField(
              label: 'Nom complet',
              ctrl: _nameCtrl,
              isEditing: _isEditing,
            ),
            const SizedBox(height: 12),
            _ProfileField(
              label: 'Téléphone',
              ctrl: _phoneCtrl,
              isEditing: _isEditing,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            _ProfileField(
              label: 'Email',
              ctrl: _emailCtrl,
              isEditing: _isEditing,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            _ProfileField(
              label: 'Adresse de livraison par défaut',
              ctrl: _quartierCtrl,
              isEditing: _isEditing,
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // Stats
        _ProfileCard(
          title: 'Mon activité',
          icon: Icons.bar_chart_outlined,
          child: Row(children: [
            _StatBlock(value: '4', label: 'Commandes'),
            _Divider(),
            _StatBlock(value: '23 800', label: 'FCFA dépensés'),
            _Divider(),
            _StatBlock(value: '3', label: 'Fermes notées'),
          ]),
        ),
        const SizedBox(height: 16),

        // Paramètres
        _ProfileCard(
          title: 'Paramètres',
          icon: Icons.settings_outlined,
          child: Column(children: [
            _SettingRow(
              icon: Icons.notifications_outlined,
              label: 'Notifications push',
              trailing: Switch(
                value: true,
                activeColor: AppColors.primary,
                onChanged: (_) {},
              ),
            ),
            const Divider(height: 1),
            _SettingRow(
              icon: Icons.language_outlined,
              label: 'Langue',
              trailing: const Text('Français',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.textSecondary)),
            ),
            const Divider(height: 1),
            _SettingRow(
              icon: Icons.help_outline,
              label: 'Aide et support',
              onTap: () {},
            ),
            const Divider(height: 1),
            _SettingRow(
              icon: Icons.privacy_tip_outlined,
              label: 'Politique de confidentialité',
              onTap: () {},
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // Déconnexion
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout_outlined,
                color: AppColors.error, size: 18),
            label: const Text('Se déconnecter',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.error)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ]),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Se déconnecter ?',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700)),
        content: const Text(
            'Vous serez redirigé vers l\'écran de connexion.',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(context);
              Get.offAllNamed(AppRoutes.login);
            },
            child: const Text('Déconnecter',
                style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }
}

// ─── Widgets réutilisables ────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _ProfileCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final bool isEditing;
  final TextInputType? keyboardType;

  const _ProfileField({
    required this.label,
    required this.ctrl,
    required this.isEditing,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        isEditing
            ? TextFormField(
                controller: ctrl,
                keyboardType: keyboardType,
                decoration: InputDecoration(hintText: label),
              )
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(ctrl.text,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: AppColors.textPrimary)),
              ),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingRow({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppColors.textPrimary)),
          ),
          trailing ??
              const Icon(Icons.chevron_right,
                  size: 18, color: AppColors.textSecondary),
        ]),
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String value;
  final String label;
  const _StatBlock({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Text(value,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary)),
        const SizedBox(height: 3),
        Text(label,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: AppColors.textSecondary),
            textAlign: TextAlign.center),
      ]),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1,
        height: 40,
        color: AppColors.divider,
        margin: const EdgeInsets.symmetric(horizontal: 8));
  }
}