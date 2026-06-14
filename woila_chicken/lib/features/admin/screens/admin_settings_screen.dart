import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = Get.find<FirestoreService>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: AppColors.adminColor,
      ),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: firestore.getSettings(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primary),
            );
          }
          final settings = snap.data ?? {};
          return _SettingsBody(settings: settings);
        },
      ),
    );
  }
}

class _SettingsBody extends StatefulWidget {
  final Map<String, dynamic> settings;
  const _SettingsBody({required this.settings});

  @override
  State<_SettingsBody> createState() => _SettingsBodyState();
}

class _SettingsBodyState extends State<_SettingsBody> {
  late TextEditingController _commissionCtrl;
  late TextEditingController _deliveryFeeCtrl;
  late TextEditingController _platformNameCtrl;
  late TextEditingController _contactEmailCtrl;
  late TextEditingController _contactPhoneCtrl;
  late TextEditingController _cityCtrl;

  late bool _notifNewOrder;
  late bool _notifNewFarm;
  late bool _notifDispute;
  late bool _maintenanceMode;
  late bool _allowNewRegistrations;
  late bool _requireSanitaryCert;

  bool _editingPlatform = false;
  bool _editingContact = false;
  bool _isSaving = false;

  final _firestore = Get.find<FirestoreService>();
  final _auth = Get.find<AuthService>();

  @override
  void initState() {
    super.initState();
    _initFromSettings(widget.settings);
  }

  void _initFromSettings(Map<String, dynamic> s) {
    _commissionCtrl = TextEditingController(
        text: '${s['commissionRate'] ?? 2}');
    _deliveryFeeCtrl = TextEditingController(
        text: '${s['deliveryFee'] ?? 500}');
    _platformNameCtrl = TextEditingController(
        text: s['platformName'] ?? 'Woïla Chicken');
    _contactEmailCtrl = TextEditingController(
        text: s['contactEmail'] ?? '');
    _contactPhoneCtrl = TextEditingController(
        text: s['contactPhone'] ?? '');
    _cityCtrl =
        TextEditingController(text: s['city'] ?? 'Garoua');
    _notifNewOrder = s['notifNewOrder'] ?? true;
    _notifNewFarm = s['notifNewFarm'] ?? true;
    _notifDispute = s['notifDispute'] ?? true;
    _maintenanceMode = s['maintenanceMode'] ?? false;
    _allowNewRegistrations = s['allowNewRegistrations'] ?? true;
    _requireSanitaryCert = s['requireSanitaryCert'] ?? false;
  }

  Future<void> _save(Map<String, dynamic> patch) async {
    setState(() => _isSaving = true);
    try {
      await _firestore.updateSettings(patch);
      Get.snackbar(
        'Enregistré',
        'Paramètres mis à jour avec succès',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'enregistrer les paramètres',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      desktop: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: _buildContent(isDesktop: true),
        ),
      ),
      mobile: _buildContent(isDesktop: false),
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

  // ── Plateforme ────────────────────────────────────────────────
  Widget _buildPlatformSection() {
    return _SettingsCard(
      title: 'Paramètres plateforme',
      icon: Icons.tune_outlined,
      trailing: _isSaving
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primary))
          : TextButton(
              onPressed: () async {
                if (_editingPlatform) {
                  await _save({
                    'platformName': _platformNameCtrl.text.trim(),
                    'commissionRate':
                        double.tryParse(_commissionCtrl.text) ?? 2,
                    'deliveryFee':
                        double.tryParse(_deliveryFeeCtrl.text) ?? 500,
                    'city': _cityCtrl.text.trim(),
                  });
                }
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
          helperText: 'Prélevé automatiquement sur chaque transaction',
        ),
        const SizedBox(height: 12),
        _SettingsField(
          label: 'Frais de livraison (FCFA)',
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

  // ── Contact ───────────────────────────────────────────────────
  Widget _buildContactSection() {
    return _SettingsCard(
      title: 'Informations de contact',
      icon: Icons.contact_mail_outlined,
      trailing: TextButton(
        onPressed: () async {
          if (_editingContact) {
            await _save({
              'contactEmail': _contactEmailCtrl.text.trim(),
              'contactPhone': _contactPhoneCtrl.text.trim(),
            });
          }
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

  // ── Notifications ─────────────────────────────────────────────
  Widget _buildNotifSection() {
    return _SettingsCard(
      title: 'Notifications admin',
      icon: Icons.notifications_outlined,
      child: Column(children: [
        _ToggleRow(
          label: 'Nouvelle commande',
          sublabel: 'Recevoir une alerte à chaque nouvelle commande',
          value: _notifNewOrder,
          onChanged: (v) async {
            setState(() => _notifNewOrder = v);
            await _save({'notifNewOrder': v});
          },
        ),
        const Divider(height: 20),
        _ToggleRow(
          label: 'Nouvelle ferme inscrite',
          sublabel: 'Alerte quand une ferme demande à rejoindre',
          value: _notifNewFarm,
          onChanged: (v) async {
            setState(() => _notifNewFarm = v);
            await _save({'notifNewFarm': v});
          },
        ),
        const Divider(height: 20),
        _ToggleRow(
          label: 'Nouveau litige',
          sublabel: 'Alerte immédiate en cas de litige client',
          value: _notifDispute,
          onChanged: (v) async {
            setState(() => _notifDispute = v);
            await _save({'notifDispute': v});
          },
        ),
      ]),
    );
  }

  // ── Règles ────────────────────────────────────────────────────
  Widget _buildRulesSection() {
    return _SettingsCard(
      title: 'Règles de la plateforme',
      icon: Icons.rule_outlined,
      child: Column(children: [
        _ToggleRow(
          label: 'Nouvelles inscriptions',
          sublabel: 'Autoriser de nouvelles fermes à s\'inscrire',
          value: _allowNewRegistrations,
          onChanged: (v) async {
            setState(() => _allowNewRegistrations = v);
            await _save({'allowNewRegistrations': v});
          },
        ),
        const Divider(height: 20),
        _ToggleRow(
          label: 'Certification sanitaire obligatoire',
          sublabel:
              'Exiger la certification pour publier un produit',
          value: _requireSanitaryCert,
          onChanged: (v) async {
            setState(() => _requireSanitaryCert = v);
            await _save({'requireSanitaryCert': v});
          },
        ),
      ]),
    );
  }

  // ── Compte ────────────────────────────────────────────────────
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

  // ── Zone danger ───────────────────────────────────────────────
  Widget _buildDangerSection() {
    return _SettingsCard(
      title: 'Zone de danger',
      icon: Icons.warning_amber_outlined,
      titleColor: AppColors.error,
      child: Column(children: [
        _ToggleRow(
          label: 'Mode maintenance',
          sublabel:
              'Suspendre l\'accès à la plateforme pour tous les utilisateurs. Les clients verront un écran de maintenance.',
          value: _maintenanceMode,
          activeColor: AppColors.error,
          onChanged: (v) {
            if (v) {
              _confirmMaintenance();
            } else {
              _disableMaintenance();
            }
          },
        ),
        const Divider(height: 20),
        _ActionRow(
          icon: Icons.delete_forever_outlined,
          label: 'Purger les données de test',
          sublabel:
              'Supprime les commandes abandonnées (+24h) créées pendant les tests',
          color: AppColors.error,
          onTap: () => _confirmPurge(),
        ),
      ]),
    );
  }

  // ── Dialogs ───────────────────────────────────────────────────
  void _confirmMaintenance() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Activer la maintenance ?',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700)),
        content: const Text(
          'Tous les clients et éleveurs verront un écran de maintenance et ne pourront plus utiliser l\'app. Seul l\'admin garde l\'accès.\n\nCette action est immédiate.',
          style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.textSecondary),
        ),
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
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _maintenanceMode = true);
              await _save({'maintenanceMode': true});
            },
            child: const Text('Activer',
                style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }

  void _disableMaintenance() async {
    setState(() => _maintenanceMode = false);
    await _save({'maintenanceMode': false});
    Get.snackbar(
      'Maintenance désactivée',
      'La plateforme est de nouveau accessible',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _confirmPurge() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Purger les données de test ?',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700)),
        content: const Text(
          'Les commandes abandonnées depuis plus de 24h (status "en attente") seront supprimées définitivement.\n\nCette action est irréversible.',
          style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.textSecondary),
        ),
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
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firestore.purgeTestData();
                Get.snackbar(
                  'Données purgées',
                  'Les commandes de test ont été supprimées',
                  backgroundColor: AppColors.success,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              } catch (e) {
                Get.snackbar(
                  'Erreur',
                  'Impossible de purger les données',
                  backgroundColor: AppColors.error,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
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
            onPressed: () async {
              if (newCtrl.text != confirmCtrl.text) {
                Get.snackbar(
                  'Erreur',
                  'Les mots de passe ne correspondent pas',
                  backgroundColor: AppColors.error,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }
              if (newCtrl.text.length < 6) {
                Get.snackbar(
                  'Erreur',
                  'Minimum 6 caractères',
                  backgroundColor: AppColors.error,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }
              try {
                await _auth.currentUser.value
                    ?.updatePassword(newCtrl.text);
                Navigator.pop(context);
                Get.snackbar(
                  'Mot de passe modifié',
                  'Votre nouveau mot de passe est actif',
                  backgroundColor: AppColors.success,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              } catch (e) {
                Get.snackbar(
                  'Erreur',
                  'Reconnectez-vous avant de changer le mot de passe',
                  backgroundColor: AppColors.error,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text('Confirmer',
                style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }

  void _showActivityLog() {
    // Journal depuis Firestore — les notifications stockées
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
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: Get.find<FirestoreService>()
                  .getAllOrders()
                  .map((orders) => orders.take(10).toList()),
              builder: (context, snap) {
                final orders = snap.data ?? [];
                if (orders.isEmpty) {
                  return const Center(
                    child: Text('Aucune activité récente',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: AppColors.textSecondary)),
                  );
                }
                return ListView.builder(
                  controller: ctrl,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: orders.length,
                  itemBuilder: (_, i) {
                    final o = orders[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary
                                .withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                          child: const Icon(
                              Icons.receipt_long_outlined,
                              size: 18,
                              color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Commande #${o['ref'] ?? ''} — ${o['farmName'] ?? ''}',
                                style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary),
                              ),
                              Text(
                                '${o['clientName'] ?? ''} · ${o['total'] ?? 0} FCFA',
                                style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11,
                                    color:
                                        AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    );
                  },
                );
              },
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
              _auth.logout();
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
  final String? sublabel;
  final VoidCallback onTap;
  final Color color;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.sublabel,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: color)),
                if (sublabel != null) ...[
                  const SizedBox(height: 2),
                  Text(sublabel!,
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: AppColors.textSecondary)),
                ],
              ],
            ),
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