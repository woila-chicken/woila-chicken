import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/widgets/woila_toast.dart';
import 'eleveur_home_screen.dart';

class FarmProfileScreen extends StatefulWidget {
  const FarmProfileScreen({super.key});

  @override
  State<FarmProfileScreen> createState() => _FarmProfileScreenState();
}

class _FarmProfileScreenState extends State<FarmProfileScreen> {
  final _auth = Get.find<AuthService>();
  final _firestore = Get.find<FirestoreService>();

  bool _isEditing = false;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _farmId;

  final _nameCtrl = TextEditingController();
  final _ownerCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String? _photoUrl;
  bool _isUploadingPhoto = false;
  final _storage = Get.find<StorageService>();

  bool _certVet = false;
  bool _certNaturel = false;
  bool _isVerified = false;
  double _rating = 0;
  int _totalRatings = 0;

  @override
  void initState() {
    super.initState();
    _loadFarm();
  }

  Future<void> _loadFarm() async {
    final farm = await _firestore.getFarmByOwner(_auth.uid);
    if (farm != null) {
      setState(() {
        _farmId = farm['id'];
        _nameCtrl.text = farm['name'] ?? '';
        _ownerCtrl.text = farm['owner'] ?? '';
        _phoneCtrl.text = farm['phone'] ?? '';
        _locationCtrl.text = farm['location'] ?? '';
        _descCtrl.text = farm['description'] ?? '';
        _isVerified = farm['isVerified'] as bool? ?? false;
        _rating = (farm['rating'] as num?)?.toDouble() ?? 0;
        _totalRatings = farm['totalRatings'] as int? ?? 0;
        _photoUrl = farm['photoUrl'] as String?;
        final certs =
            (farm['certifications'] as List?)?.cast<String>() ?? [];
        _certVet = certs.contains('veterinaire');
        _certNaturel = certs.contains('naturel');

        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadPhoto() async {
  if (_farmId == null) return;
  final bytes = await _storage.pickImage();
  if (bytes == null) return;

  setState(() => _isUploadingPhoto = true);
  try {
    final url = await _storage.uploadImage(
      bytes: bytes,
      path: _storage.farmPath(_farmId!),
    );
    await _firestore.updateFarm(_farmId!, {'photoUrl': url});

    setState(() {
      _photoUrl = url;
      _isUploadingPhoto = false;
    });

    WoilaToast.success('Photo mise à jour',
    'La photo de votre ferme a été changée');
  } catch (e) {
    setState(() => _isUploadingPhoto = false);
    WoilaToast.error('Erreur', 'Impossible de changer la photo');
  }
}

  Future<void> _save() async {
    if (_farmId == null) return;
    setState(() => _isSaving = true);

    final certifications = <String>[
      if (_certVet) 'veterinaire',
      if (_certNaturel) 'naturel',
    ];

    try {
      await _firestore.updateFarm(_farmId!, {
        'name': _nameCtrl.text.trim(),
        'owner': _ownerCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'certifications': certifications,
      });

      WoilaToast.success('Profil mis à jour',
    'Les informations de votre ferme ont été enregistrées');
    } catch (e) {
      WoilaToast.error('Erreur', 'Impossible d\'enregistrer les modifications');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ma ferme'),
        backgroundColor: AppColors.accent,
        foregroundColor: const Color(0xFF412402),
        actions: [
          if (!_isLoading && _farmId != null)
            TextButton(
              onPressed: _isSaving
                  ? null
                  : () async {
                      if (_isEditing) {
                        await _save();
                      }
                      setState(() => _isEditing = !_isEditing);
                    },
              child: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Color(0xFF412402)),
                    )
                  : Text(
                      _isEditing ? 'Enregistrer' : 'Modifier',
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF412402)),
                    ),
            ),
                 IconButton(
    icon: const Icon(Icons.logout_outlined),
    tooltip: 'Déconnexion',
    onPressed: () => confirmLogout(context, Get.find<AuthService>()),
  ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            )
          : _farmId == null
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.store_outlined,
                          size: 56, color: AppColors.textSecondary),
                      SizedBox(height: 12),
                      Text('Aucune ferme associée à ce compte',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: AppColors.textSecondary)),
                    ],
                  ),
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
        // ── En-tête ferme ──────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: [
            GestureDetector(
  onTap: (_isEditing && !_isUploadingPhoto) ? _pickAndUploadPhoto : null,
  child: Stack(
    alignment: Alignment.bottomRight,
    children: [
      Container(
        width: 80,
        height: 80,
        decoration: const BoxDecoration(
            color: Colors.white, shape: BoxShape.circle),
        child: ClipOval(
          child: _isUploadingPhoto
              ? const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.accent, strokeWidth: 2),
                )
              : _photoUrl != null && _photoUrl!.isNotEmpty
                  ? Image.network(
                      _photoUrl!,
                      fit: BoxFit.cover,
                      width: 80,
                      height: 80,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.agriculture_rounded,
                          size: 40,
                          color: AppColors.accent),
                    )
                  : const Icon(Icons.agriculture_rounded,
                      size: 40, color: AppColors.accent),
        ),
      ),
      if (_isEditing)
        Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
              color: AppColors.primary, shape: BoxShape.circle),
          child: const Icon(Icons.camera_alt,
              color: Colors.white, size: 14),
        ),
    ],
  ),
),
            const SizedBox(height: 12),
            Text(_nameCtrl.text.isEmpty ? 'Nom de la ferme' : _nameCtrl.text,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF412402))),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: (_isVerified ? AppColors.success : AppColors.warning)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isVerified
                        ? Icons.verified_rounded
                        : Icons.pending_outlined,
                    size: 14,
                    color:
                        _isVerified ? AppColors.success : AppColors.warning,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isVerified ? 'Ferme vérifiée' : 'En attente de validation',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _isVerified
                            ? AppColors.success
                            : AppColors.warning),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ...List.generate(5, (i) {
                final filled = i < _rating.round();
                return Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: AppColors.primary,
                  size: 18,
                );
              }),
              const SizedBox(width: 6),
              Text(
                _totalRatings > 0
                    ? '${_rating.toStringAsFixed(1)} ($_totalRatings)'
                    : 'Pas encore noté',
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF412402)),
              ),
            ]),
          ]),
        ),
        const SizedBox(height: 16),

        // ── Informations ──────────────────────────────────────
        _ProfileCard(
          title: 'Informations',
          icon: Icons.info_outline,
          child: Column(children: [
            _ProfileField(
                label: 'Nom de la ferme',
                ctrl: _nameCtrl,
                isEditing: _isEditing),
            const SizedBox(height: 12),
            _ProfileField(
                label: 'Propriétaire',
                ctrl: _ownerCtrl,
                isEditing: _isEditing),
            const SizedBox(height: 12),
            _ProfileField(
                label: 'Téléphone',
                ctrl: _phoneCtrl,
                isEditing: _isEditing,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _ProfileField(
                label: 'Localisation',
                ctrl: _locationCtrl,
                isEditing: _isEditing),
            const SizedBox(height: 12),
            _ProfileField(
                label: 'Description',
                ctrl: _descCtrl,
                isEditing: _isEditing,
                maxLines: 3),
          ]),
        ),
        const SizedBox(height: 16),

        // ── Certifications ────────────────────────────────────
        _ProfileCard(
          title: 'Certifications',
          icon: Icons.shield_outlined,
          child: Column(children: [
            _CertSwitch(
              label: 'Certification sanitaire vétérinaire',
              value: _certVet,
              isEditing: _isEditing,
              onChanged: (v) => setState(() => _certVet = v),
            ),
            const SizedBox(height: 10),
            _CertSwitch(
              label: 'Élevage naturel certifié',
              value: _certNaturel,
              isEditing: _isEditing,
              onChanged: (v) => setState(() => _certNaturel = v),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // ── Statistiques réelles ──────────────────────────────
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: _firestore.getFarmOrders(_farmId!),
          builder: (context, snap) {
            final orders = snap.data ?? [];
            final completed =
                orders.where((o) => o['status'] == 'completed').toList();
            final totalEarned = completed.fold<double>(
                0, (s, o) => s + ((o['total'] as num?) ?? 0));

            return _ProfileCard(
              title: 'Statistiques',
              icon: Icons.bar_chart_outlined,
              child: Row(children: [
                _StatBlock(
                    value: '${completed.length}', label: 'Ventes totales'),
                _Divider(),
                _StatBlock(
                    value: _totalRatings > 0
                        ? '${_rating.toStringAsFixed(1)} ★'
                        : '—',
                    label: 'Note clients'),
                _Divider(),
                _StatBlock(
                    value: totalEarned.toStringAsFixed(0),
                    label: 'FCFA gagnés'),
              ]),
            );
          },
        ),
      ]),
    );
  }
}

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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
      ]),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final bool isEditing;
  final TextInputType? keyboardType;
  final int maxLines;

  const _ProfileField({
    required this.label,
    required this.ctrl,
    required this.isEditing,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
              maxLines: maxLines,
              decoration: InputDecoration(hintText: label),
            )
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
    ]);
  }
}

class _CertSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final bool isEditing;
  final ValueChanged<bool> onChanged;

  const _CertSwitch({
    required this.label,
    required this.value,
    required this.isEditing,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(
        value ? Icons.verified_outlined : Icons.cancel_outlined,
        color: value ? AppColors.success : AppColors.textSecondary,
        size: 20,
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(label,
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: value ? AppColors.textPrimary : AppColors.textSecondary)),
      ),
      if (isEditing)
        Switch(
          value: value,
          activeColor: AppColors.success,
          onChanged: onChanged,
        ),
    ]);
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
        width: 1, height: 40, color: AppColors.divider,
        margin: const EdgeInsets.symmetric(horizontal: 8));
  }
}