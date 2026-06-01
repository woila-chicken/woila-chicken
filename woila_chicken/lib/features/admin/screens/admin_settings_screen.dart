import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/routes/app_routes.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  // ── Paramètres plateforme ─────────────────────────────────────
  final _commissionCtrl = TextEditingController(text: '2');
  final _deliveryFeeCtrl = TextEditingController(text: '500');
  final _platformNameCtrl =
      TextEditingController(text: 'Woïla Chicken');
  final _contactEmailCtrl =
      TextEditingController(text: 'contact@woilachicken.cm');
  final _contactPhoneCtrl =
      TextEditingController(text: '+237 6XX XXX XXX');
  final _cityCtrl = TextEditingController(text: 'Garoua');

  // ── Toggles ───────────────────────────────────────────────────
  bool _notifNewOrder = true;
  bool _notifNewFarm = true;
  bool _notifDispute = true;
  bool _maintenanceMode = false;
  bool _allowNewRegistrations = true;
  bool _requireSanitaryCert = false;

  bool _editingPlatform = false;
  bool _editingContact = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: AppColors.adminColor,
      ),
      body: ResponsiveLayout(
        desktop: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: _buildContent(isDesktop: true),
          ),
        ),
        mobile: _buildContent(isDesktop: false),
      ),
    );
  }

  Widget _buildContent({required bool isDesktop}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(children: [
                    _buildPlatformSection(),
                    const SizedBox(height: 16),
                    _buildContactSection(),
                    const SizedBox(height: 16),
                    _buildDangerSection(),
                  ]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(children: [
                    _buildNotifSection(),
                    const SizedBox(height: 16),
                    _buildRulesSection(),
                    const SizedBox(height: 16),
                    _buildAccountSection(),
                  ]),
                ),
              ],
            )
          : Column(children: [
              _buildPlatformSection(),
              const SizedBox(height: 16),
              _buildContactSection(),
              const SizedBox(height: 16),
              _buildNotifSection(),
              const SizedBox(height: 16),
              _buildRulesSection(),
              const SizedBox(height: 16),
              _buildAccountSection(),
              const SizedBox(height: 16),
              _buildDangerSection(),
            ]),
    );
  }

  // ── Section paramètres plateforme ─────────────────────────────
  Widget _buildPlatformSection() {
    return _SettingsCard(
      title: 'Paramètres plateforme',
      icon: Icons.tune_outlined,
      trailing: TextButton(
        onPressed: () {
          if (_editingPlatform) _savePlatform();
          setState(() => _editingPlatform = !_editingPlatform);
        },
        child: Text(
          _editingPlatform ? 'Enregistrer' : 'Modifier',
          style: const TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.primary,
              fontWeight: FontWeight.w600),
        ),
      ),
      child: Column(children: [
        _SettingsField(
          label: 'Nom de la plateforme',
          ctrl: _platformNameCtrl,
          isEditing: _editingPlatform,
        ),
        const SizedBox(height: 12),
        _SettingsField(
          label: 'Taux de commission (%)',
          ctrl: _commissionCtrl,
          isEditing: _editingPlatform,
          keyboardType: TextInputType.number,
          suffix: '%',
          helperText:
              'Prélevé automatiquement sur chaque transaction',
        ),
        const SizedBox(height: 12),
        _SettingsField(
          label: 'Frais de livraison fixe (FCFA)',
          ctrl: _deliveryFeeCtrl,
          isEditing: _editingPlatform,
          keyboardType: TextInputType.number,
          suffix: 'FCFA',
          helperText: 'Appliqué à chaque commande avec livraison',
        ),
        const SizedBox(height: 12),
        _SettingsField(
          label: 'Ville principale',
          ctrl: _cityCtrl,
          isEditing: _editingPlatform,
        ),
      ]),
    );
  }

  // ── Section contact ────────────────────────────────────────────
  Widget _buildContactSection() {
    return _SettingsCard(
      title: 'Informations de contact',
      icon: Icons.contact_mail_outlined,
      trailing: TextButton(
        onPressed: () {
          if (_editingContact) _saveContact();
          setState(() => _editingContact = !_editingContact);
        },
        child: Text(
          _editingContact ? 'Enregistrer' : 'Modifier',
          style: const TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.primary,
              fontWeight: FontWeight.w600),
        ),
      ),
      child: Column(children: [
        _SettingsField(
          label: 'Email de support',
          ctrl: _contactEmailCtrl,
          isEditing: _editingContact,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        _SettingsField(
          label: 'Téléphone de support',
          ctrl: _contactPhoneCtrl,
          isEditing: _editingContact,
          keyboardType: TextInputType.phone,
        ),
      ]),
    );
  }

  // ── Section notifications ──────────────────────────────────────
  Widget _buildNotifSection() {
    return _SettingsCard(
      title: 'Notifications admin',
      icon: Icons.notifications_outlined,
      child: Column(children: [
        _ToggleRow(
          label: 'Nouvelle commande',
          sublabel: 'Recevoir une alerte à chaque nouvelle commande',
          value: _notifNewOrder,
          onChanged: (v) => setState(() => _notifNewOrder = v),
        ),
        const Divider(height: 20),
        _ToggleRow(
          label: 'Nouvelle ferme inscrite',
          sublabel: 'Alerte quand une ferme demande à rejoindre',
          value: _notifNewFarm,
          onChanged: (v) => setState(() => _notifNewFarm = v),
        ),
        const Divider(height: 20),
        _ToggleRow(
          label: 'Nouveau litige',
          sublabel: 'Alerte immédiate en cas de litige client',
          value: _notifDispute,
          onChanged: (v) => setState(() => _notifDispute = v),
        ),
      ]),
    );
  }

  // ── Section règles ────────────────────────────────────────────
  Widget _buildRulesSection() {
    return _SettingsCard(
      title: 'Règles de la plateforme',
      icon: Icons.rule_outlined,
      child: Column(children: [
        _ToggleRow(
          label: 'Nouvelles inscriptions',
          sublabel:
              'Autoriser de nouvelles fermes à s\'inscrire',
          value: _allowNewRegistrations,
          onChanged: (v) =>
              setState(() => _allowNewRegistrations = v),
        ),
        const Divider(height: 20),
        _ToggleRow(
          label: 'Certification sanitaire obligatoire',
          sublabel:
              'Exiger la certification pour publier un produit',
          value: _requireSanitaryCert,
          onChanged: (v) =>
              setState(() => _requireSanitaryCert = v),
        ),
      ]),
    );
  }

  // ── Section compte admin ───────────────────────────────────────
  Widget _buildAccountSection() {
    return _SettingsCard(
      title: 'Compte administrateur',
      icon: Icons.admin_panel_settings_outlined,
      child: Column(children: [
        _ActionRow(
          icon: Icons.lock_outline,
          label: 'Changer le mot de passe',
          onTap: () => _showChangePasswordDialog(),
        ),
        const Divider(height: 1),
        _ActionRow(
          icon: Icons.history_outlined,
          label: 'Journal d\'activité',
          onTap: () => _showActivityLog(),
        ),
        const Divider(height: 1),
        _ActionRow(
          icon: Icons.logout_outlined,
          label: 'Se déconnecter',
          color: AppColors.error,
          onTap: () => _confirmLogout(),
        ),
      ]),
    );
  }

  // ── Section danger ────────────────────────────────────────────
  Widget _buildDangerSection() {
    return _SettingsCard(
      title: 'Zone de danger',
      icon: Icons.warning_amber_outlined,
      titleColor: AppColors.error,
      child: Column(children: [
        _ToggleRow(
          label: 'Mode maintenance',
          sublabel:
              'Suspendre l\'accès à la plateforme pour tous les utilisateurs',
          value: _maintenanceMode,
          activeColor: AppColors.error,
          onChanged: (v) {
            if (v) {
              _confirmMaintenance(v);
            } else {
              setState(() => _maintenanceMode = false);
            }
          },
        ),
        const Divider(height: 20),
        _ActionRow(
          icon: Icons.delete_forever_outlined,
          label: 'Purger les données de test',
          color: AppColors.error,
          onTap: () => _confirmPurge(),
        ),
      ]),
    );
  }

  // ── Dialogs ───────────────────────────────────────────────────
  void _savePlatform() {
    Get.snackbar(
      'Paramètres enregistrés',
      'Commission : ${_commissionCtrl.text}% · Livraison : ${_deliveryFeeCtrl.text} FCFA',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void _saveContact() {
    Get.snackbar(
      'Contact mis à jour',
      _contactEmailCtrl.text,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void _confirmMaintenance(bool v) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Activer le mode maintenance ?',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700)),
        content: const Text(
            'Tous les utilisateurs seront déconnectés et la plateforme sera inaccessible jusqu\'à désactivation.',
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
              setState(() => _maintenanceMode = true);
              Navigator.pop(context);
              Get.snackbar(
                'Mode maintenance activé',
                'La plateforme est maintenant inaccessible',
                backgroundColor: AppColors.error,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Activer',
                style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }

  void _confirmPurge() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Purger les données ?',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700)),
        content: const Text(
            'Toutes les données de test seront supprimées définitivement. Cette action est irréversible.',
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
              Get.snackbar(
                'Données purgées',
                'Les données de test ont été supprimées',
                backgroundColor: AppColors.error,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Purger',
                style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Changer le mot de passe',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _DialogField(
              ctrl: currentCtrl,
              label: 'Mot de passe actuel',
              isPassword: true),
          const SizedBox(height: 12),
          _DialogField(
              ctrl: newCtrl,
              label: 'Nouveau mot de passe',
              isPassword: true),
          const SizedBox(height: 12),
          _DialogField(
              ctrl: confirmCtrl,
              label: 'Confirmer le nouveau',
              isPassword: true),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.snackbar(
                'Mot de passe modifié',
                'Votre nouveau mot de passe est actif',
                backgroundColor: AppColors.success,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Confirmer',
                style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }

  void _showActivityLog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, ctrl) => Column(children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              const Text('Journal d\'activité',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ]),
          ),
          Expanded(
            child: ListView(
              controller: ctrl,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: const [
                _LogItem(
                  action: 'Ferme Sadou validée',
                  time: 'Aujourd\'hui · 10:32',
                  icon: Icons.verified_outlined,
                  color: AppColors.success,
                ),
                _LogItem(
                  action: 'Litige #WC-1035 résolu',
                  time: 'Aujourd\'hui · 09:15',
                  icon: Icons.gavel_outlined,
                  color: AppColors.primary,
                ),
                _LogItem(
                  action: 'Commission modifiée : 1.5% → 2%',
                  time: 'Hier · 16:44',
                  icon: Icons.tune_outlined,
                  color: AppColors.warning,
                ),
                _LogItem(
                  action: 'Ferme Alhadji suspendue',
                  time: 'Hier · 11:20',
                  icon: Icons.block_outlined,
                  color: AppColors.error,
                ),
                _LogItem(
                  action: 'Connexion admin',
                  time: '8 mai · 08:05',
                  icon: Icons.login_outlined,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  void _confirmLogout() {
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

// ─────────────────────────────────────────────────────────────────
//  Widgets réutilisables
// ─────────────────────────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;
  final Color? titleColor;

  const _SettingsCard({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
    this.titleColor,
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
            Icon(icon,
                color: titleColor ?? AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title,
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: titleColor ?? AppColors.textPrimary)),
            ),
            if (trailing != null) trailing!,
          ]),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SettingsField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final bool isEditing;
  final TextInputType? keyboardType;
  final String? suffix;
  final String? helperText;

  const _SettingsField({
    required this.label,
    required this.ctrl,
    required this.isEditing,
    this.keyboardType,
    this.suffix,
    this.helperText,
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
                decoration: InputDecoration(
                  hintText: label,
                  suffixText: suffix,
                  helperText: helperText,
                  helperStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: AppColors.textSecondary),
                ),
              )
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  Expanded(
                    child: Text(ctrl.text,
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: AppColors.textPrimary)),
                  ),
                  if (suffix != null)
                    Text(suffix!,
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: AppColors.textSecondary)),
                ]),
              ),
        if (helperText != null && !isEditing) ...[
          const SizedBox(height: 3),
          Text(helperText!,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  color: AppColors.textSecondary)),
        ],
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String sublabel;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  const _ToggleRow({
    required this.label,
    required this.sublabel,
    required this.value,
    required this.onChanged,
    this.activeColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(sublabel,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppColors.textSecondary)),
          ],
        ),
      ),
      Switch(
        value: value,
        activeColor: activeColor,
        onChanged: onChanged,
      ),
    ]);
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: color)),
          ),
          Icon(Icons.chevron_right,
              size: 18, color: color.withOpacity(0.5)),
        ]),
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final bool isPassword;

  const _DialogField({
    required this.ctrl,
    required this.label,
    this.isPassword = false,
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
        TextFormField(
          controller: ctrl,
          obscureText: isPassword,
          decoration: InputDecoration(hintText: label),
        ),
      ],
    );
  }
}

class _LogItem extends StatelessWidget {
  final String action;
  final String time;
  final IconData icon;
  final Color color;

  const _LogItem({
    required this.action,
    required this.time,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(action,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              Text(time,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: AppColors.textSecondary)),
            ],
          ),
        ),
      ]),
    );
  }
}