import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/widgets/woila_toast.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = Get.find<AuthService>();
  final _firestore = Get.find<FirestoreService>();

  bool _isEditing = false;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _notifEnabled = true;

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  String? _photoUrl;
  bool _isUploadingAvatar = false;
  final _storage = Get.find<StorageService>();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
  // Attendre que l'uid soit disponible
  if (_auth.uid.isEmpty) {
    setState(() => _isLoading = false);
    return;
  }

  try {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.uid)
        .get();
    if (!mounted) return;
    final data = doc.data() ?? {};
    setState(() {
      _nameCtrl.text = data['name'] ?? '';
      _phoneCtrl.text = data['phone'] ?? '';
      _emailCtrl.text =
          data['email'] ?? _auth.currentUser.value?.email ?? '';
      _addressCtrl.text = data['address'] ?? '';
      _notifEnabled = data['notifEnabled'] as bool? ?? true;
      _photoUrl = data['photoUrl'] as String?;
      _isLoading = false;
    });
  } catch (e) {
    debugPrint('Erreur loadProfile: $e');
    if (!mounted) return;
    setState(() {
      // Charger au moins l'email depuis l'auth même si Firestore échoue
      _emailCtrl.text = _auth.currentUser.value?.email ?? '';
      _isLoading = false;
    });
  }
}

  Future<void> _pickAndUploadAvatar() async {
  final bytes = await _storage.pickImage();
  if (bytes == null) return;

  setState(() => _isUploadingAvatar = true);
  try {
    final url = await _storage.uploadImage(
      bytes: bytes,
      path: _storage.profilePath(_auth.uid),
    );
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.uid)
        .set({'photoUrl': url}, SetOptions(merge: true));

    setState(() {
      _photoUrl = url;
      _isUploadingAvatar = false;
    });

    WoilaToast.success('Photo mise à jour',
    'Votre photo de profil a été changée');
  } catch (e) {
    setState(() => _isUploadingAvatar = false);
    WoilaToast.error('Erreur', 'Impossible de changer la photo');
  }
}

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.uid)
          .set({
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
      }, SetOptions(merge: true));

      WoilaToast.success('Profil mis à jour',
    'Vos informations ont été enregistrées');
    } catch (e) {
      WoilaToast.error('Erreur', 'Impossible d\'enregistrer les modifications');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _toggleNotif(bool v) async {
    setState(() => _notifEnabled = v);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.uid)
        .set({'notifEnabled': v}, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mon profil'),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _isSaving
                  ? null
                  : () async {
                      if (_isEditing) await _save();
                      setState(() => _isEditing = !_isEditing);
                    },
              child: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      _isEditing ? 'Enregistrer' : 'Modifier',
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : ResponsiveLayout(
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
        // ── Avatar ─────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: [
            GestureDetector(
  onTap: (_isEditing && !_isUploadingAvatar) ? _pickAndUploadAvatar : null,
  child: Stack(
    alignment: Alignment.bottomRight,
    children: [
      Container(
        width: 80,
        height: 80,
        decoration: const BoxDecoration(
            color: Colors.white, shape: BoxShape.circle),
        child: ClipOval(
          child: _isUploadingAvatar
              ? const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primary, strokeWidth: 2),
                )
              : _photoUrl != null && _photoUrl!.isNotEmpty
                  ? Image.network(
                      _photoUrl!,
                      fit: BoxFit.cover,
                      width: 80,
                      height: 80,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.person,
                          size: 44,
                          color: AppColors.primary),
                    )
                  : const Icon(Icons.person,
                      size: 44, color: AppColors.primary),
        ),
      ),
      if (_isEditing)
        Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
              color: AppColors.accent, shape: BoxShape.circle),
          child: const Icon(Icons.camera_alt,
              size: 14, color: Color(0xFF412402)),
        ),
    ],
  ),
),
            const SizedBox(height: 12),
            Text(
              _nameCtrl.text.isEmpty ? 'Client Woïla' : _nameCtrl.text,
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
                  color: Colors.white.withValues(alpha: 0.75)),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // ── Infos personnelles ────────────────────────────────
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
              isEditing: false, // email non modifiable (lié à l'auth)
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            _ProfileField(
              label: 'Adresse de livraison par défaut',
              ctrl: _addressCtrl,
              isEditing: _isEditing,
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // ── Activité réelle ────────────────────────────────────
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: _firestore.getClientOrders(_auth.uid),
          builder: (context, snap) {
            final orders = snap.data ?? [];
            final completed =
                orders.where((o) => o['status'] == 'completed').toList();
            final totalSpent = orders.fold<double>(
                0, (s, o) => s + ((o['total'] as num?) ?? 0));

            return _ProfileCard(
              title: 'Mon activité',
              icon: Icons.bar_chart_outlined,
              child: Row(children: [
                _StatBlock(value: '${orders.length}', label: 'Commandes'),
                _Divider(),
                _StatBlock(
                    value: totalSpent.toStringAsFixed(0),
                    label: 'FCFA dépensés'),
                _Divider(),
                _StatBlock(
                    value: '${completed.length}', label: 'Terminées'),
              ]),
            );
          },
        ),
        const SizedBox(height: 16),

        // ── Paramètres ─────────────────────────────────────────
        _ProfileCard(
          title: 'Paramètres',
          icon: Icons.settings_outlined,
          child: Column(children: [
            _SettingRow(
              icon: Icons.notifications_outlined,
              label: 'Notifications push',
              trailing: Switch(
                value: _notifEnabled,
                activeColor: AppColors.primary,
                onChanged: _toggleNotif,
              ),
            ),
            const Divider(height: 1),
            const _SettingRow(
              icon: Icons.language_outlined,
              label: 'Langue',
              trailing: Text('Français',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.textSecondary)),
            ),
            const Divider(height: 1),
            _SettingRow(
              icon: Icons.help_outline,
              label: 'Aide et support',
              onTap: () {
                WoilaToast.info('Support', 'Contactez-nous à woila.chicken.cm@gmail.com');
              },
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

        // ── Déconnexion ────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout_outlined,
                color: AppColors.error, size: 18),
            label: const Text('Se déconnecter',
                style: TextStyle(
                    fontFamily: 'Poppins', color: AppColors.error)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Se déconnecter ?',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        content: const Text('Vous serez redirigé vers l\'écran de connexion.',
            style: TextStyle(
                fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
                style: TextStyle(
                    fontFamily: 'Poppins', color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  ctrl.text.isEmpty ? 'Non renseigné' : ctrl.text,
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: ctrl.text.isEmpty
                          ? AppColors.textSecondary
                          : AppColors.textPrimary),
                ),
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