import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';

class FarmProfileScreen extends StatefulWidget {
  const FarmProfileScreen({super.key});

  @override
  State<FarmProfileScreen> createState() => _FarmProfileScreenState();
}

class _FarmProfileScreenState extends State<FarmProfileScreen> {
  bool _isEditing = false;

  final _nameCtrl       = TextEditingController(text: 'Ferme Bougué');
  final _ownerCtrl      = TextEditingController(text: 'M. Bougué');
  final _phoneCtrl      = TextEditingController(text: '+237 6XX XXX XXX');
  final _locationCtrl   = TextEditingController(text: 'Garoua, Nord Cameroun');
  final _descCtrl       = TextEditingController(
      text: 'Élevage familial depuis 2010. Spécialisé dans les poulets fermiers élevés en plein air, nourris naturellement sans hormones.');

  bool _certVet     = true;
  bool _certNaturel = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ma ferme'),
        backgroundColor: AppColors.accent,
        foregroundColor: const Color(0xFF412402),
        actions: [
          TextButton(
            onPressed: () => setState(() => _isEditing = !_isEditing),
            child: Text(
              _isEditing ? 'Enregistrer' : 'Modifier',
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF412402)),
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
        // En-tête ferme
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.accent,
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
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.asset('assets/images/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.agriculture_rounded, size: 36, color: AppColors.accent),)),
                    ),
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
            const SizedBox(height: 12),
            Text(_nameCtrl.text,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF412402))),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('✓ Ferme vérifiée',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success)),
            ),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ...List.generate(5, (i) => const Icon(Icons.star,
                  color: AppColors.primary, size: 18)),
              const SizedBox(width: 6),
              const Text('4.8',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF412402))),
            ]),
          ]),
        ),
        const SizedBox(height: 16),

        // Informations
        _ProfileCard(
          title: 'Informations',
          icon: Icons.info_outline,
          child: Column(children: [
            _ProfileField(label: 'Nom de la ferme', ctrl: _nameCtrl,
                isEditing: _isEditing),
            const SizedBox(height: 12),
            _ProfileField(label: 'Propriétaire', ctrl: _ownerCtrl,
                isEditing: _isEditing),
            const SizedBox(height: 12),
            _ProfileField(label: 'Téléphone', ctrl: _phoneCtrl,
                isEditing: _isEditing,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _ProfileField(label: 'Localisation', ctrl: _locationCtrl,
                isEditing: _isEditing),
            const SizedBox(height: 12),
            _ProfileField(label: 'Description', ctrl: _descCtrl,
                isEditing: _isEditing, maxLines: 3),
          ]),
        ),
        const SizedBox(height: 16),

        // Certifications
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

        // Stats
        _ProfileCard(
          title: 'Statistiques',
          icon: Icons.bar_chart_outlined,
          child: Row(children: [
            const _StatBlock(value: '21', label: 'Ventes ce mois'),
            _Divider(),
            const _StatBlock(value: '4.8 ★', label: 'Note clients'),
            _Divider(),
            const _StatBlock(value: '47 500', label: 'FCFA gagnés'),
          ]),
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
                color: value
                    ? AppColors.textPrimary
                    : AppColors.textSecondary)),
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