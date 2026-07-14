import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/widgets/woila_toast.dart';
import '../controllers/stock_controller.dart';

// ─────────────────────────────────────────────────────────────────
//  ÉCRAN PRINCIPAL STOCK
// ─────────────────────────────────────────────────────────────────
class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(StockController());
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mon stock'),
        backgroundColor: AppColors.accent,
        foregroundColor: const Color(0xFF412402),
      ),
      floatingActionButton: Obx(() {
        if (ctrl.farmId.value == null) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: () => _openForm(context, ctrl, null),
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Ajouter',
              style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
        );
      }),
      body: ResponsiveLayout(
        desktop: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: _buildList(context, ctrl),
            ),
          ),
        ),
        mobile: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildList(context, ctrl),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, StockController ctrl) {
    return Obx(() {
      if (ctrl.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        );
      }
      if (ctrl.items.isEmpty) {
        return const Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.inventory_2_outlined,
                size: 64, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text('Aucun produit en stock',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: AppColors.textSecondary)),
            SizedBox(height: 8),
            Text('Appuyez sur "Ajouter" pour commencer',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.textSecondary)),
          ]),
        );
      }
      return ListView.separated(
        itemCount: ctrl.items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final item = ctrl.items[i];
          final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
          final isLow = quantity <= 2;
          final isCertified = item['isCertified'] as bool? ?? false;
          final priceFcfa = (item['priceFcfa'] as num?)?.toDouble() ?? 0;
          final photoUrl = item['photoUrl'] as String? ?? '';

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isLow
                    ? AppColors.warning.withValues(alpha: 0.5)
                    : AppColors.divider,
              ),
            ),
            child: Row(children: [
              // Image produit
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: photoUrl.isNotEmpty
                      ? Image.network(photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.egg_rounded,
                              color: AppColors.primary,
                              size: 28))
                      : const Icon(Icons.egg_rounded,
                          color: AppColors.primary, size: 28),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['name'] ?? '',
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 3),
                      Row(children: [
                        Text('${priceFcfa.toInt()} FCFA',
                            style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary)),
                        const SizedBox(width: 10),
                        if (isCertified)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified_rounded,
                                    size: 11, color: AppColors.success),
                                SizedBox(width: 3),
                                Text('Certifié',
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 10,
                                        color: AppColors.success,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                      ]),
                      const SizedBox(height: 3),
                      Row(children: [
                        Icon(
                          isLow
                              ? Icons.warning_amber_rounded
                              : Icons.inventory_2_outlined,
                          size: 13,
                          color: isLow
                              ? AppColors.warning
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Stock : $quantity${isLow ? ' — Faible' : ''}',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: isLow
                                  ? AppColors.warning
                                  : AppColors.textSecondary,
                              fontWeight:
                                  isLow ? FontWeight.w600 : FontWeight.normal),
                        ),
                      ]),
                    ]),
              ),
              Column(children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      color: AppColors.primary, size: 20),
                  onPressed: () => _openForm(context, ctrl, item),
                  tooltip: 'Modifier',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.error, size: 20),
                  onPressed: () => _confirmDelete(context, ctrl, item),
                  tooltip: 'Supprimer',
                ),
              ]),
            ]),
          );
        },
      );
    });
  }

  // Ouvre le formulaire — panneau latéral sur desktop, page sur mobile
  void _openForm(BuildContext context, StockController ctrl,
      Map<String, dynamic>? existing) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    if (isDesktop) {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Fermer',
        barrierColor: Colors.black.withValues(alpha: 0.3),
        transitionDuration: const Duration(milliseconds: 220),
        transitionBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        pageBuilder: (ctx, _, __) => Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 520,
            height: double.infinity,
            child: Material(
              color: Colors.white,
              child: _ProductFormPanel(
                existing: existing,
                ctrl: ctrl,
                onClose: () => Navigator.pop(ctx),
              ),
            ),
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _ProductFormPage(
            existing: existing,
            ctrl: ctrl,
          ),
        ),
      );
    }
  }

  void _confirmDelete(
      BuildContext context, StockController ctrl, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer ce produit ?',
            style:
                TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        content: Text('${item['name']} sera retiré de votre catalogue.',
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
                style: TextStyle(
                    color: AppColors.textSecondary, fontFamily: 'Poppins')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              await ctrl.deleteItem(item['id']);
              if (!context.mounted) return;
              Navigator.pop(context);
              WoilaToast.success(
                  'Produit supprimé', '${item['name']} retiré du catalogue');
            },
            child: const Text('Supprimer',
                style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  FORMULAIRE PARTAGÉ (logique commune desktop + mobile)
// ─────────────────────────────────────────────────────────────────
class _ProductFormState {
  final nameCtrl = TextEditingController();
  final weightCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  int quantity = 1;
  bool isCertified = false;
  bool deliveryAvailable = true;
  bool pickupAvailable = true;
  Uint8List? imageBytes;
  String? existingPhotoUrl;
  bool isSaving = false;
  bool isPickingImage = false;

  void fillFrom(Map<String, dynamic>? existing) {
    if (existing == null) return;
    nameCtrl.text = existing['name'] ?? '';
    weightCtrl.text = existing['weightKg']?.toString() ?? '';
    priceCtrl.text = existing['priceFcfa']?.toInt().toString() ?? '';
    descCtrl.text = existing['description'] ?? '';
    quantity = (existing['quantity'] as num?)?.toInt() ?? 1;
    isCertified = existing['isCertified'] ?? false;
    deliveryAvailable = existing['deliveryAvailable'] ?? true;
    pickupAvailable = existing['pickupAvailable'] ?? true;
    existingPhotoUrl = existing['photoUrl'] as String?;
  }

  void dispose() {
    nameCtrl.dispose();
    weightCtrl.dispose();
    priceCtrl.dispose();
    descCtrl.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────
//  PANNEAU LATÉRAL DESKTOP
// ─────────────────────────────────────────────────────────────────
class _ProductFormPanel extends StatefulWidget {
  final Map<String, dynamic>? existing;
  final StockController ctrl;
  final VoidCallback onClose;

  const _ProductFormPanel({
    required this.existing,
    required this.ctrl,
    required this.onClose,
  });

  @override
  State<_ProductFormPanel> createState() => _ProductFormPanelState();
}

class _ProductFormPanelState extends State<_ProductFormPanel> {
  late final _ProductFormState _form;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _form = _ProductFormState();
    _form.fillFrom(widget.existing);
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Column(children: [
      // Header
      Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(children: [
          Text(isEdit ? 'Modifier le produit' : 'Ajouter un produit',
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const Spacer(),
          IconButton(
            icon:
                const Icon(Icons.close_rounded, color: AppColors.textSecondary),
            onPressed: widget.onClose,
          ),
        ]),
      ),

      // Formulaire
      Expanded(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _buildFormContent(),
          ),
        ),
      ),

      // Boutons
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: widget.onClose,
              child: const Text('Annuler',
                  style: TextStyle(fontFamily: 'Poppins')),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _form.isSaving ? null : _save,
              child: _form.isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(isEdit ? 'Enregistrer' : 'Ajouter',
                      style: const TextStyle(fontFamily: 'Poppins')),
            ),
          ),
        ]),
      ),
    ]);
  }

  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Zone drop image
        _ImageDropZone(
          imageBytes: _form.imageBytes,
          existingPhotoUrl: _form.existingPhotoUrl,
          isLoading: _form.isPickingImage,
          onPick: _pickImage,
        ),
        const SizedBox(height: 20),

        // Nom
        const _Label('Nom du produit'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _form.nameCtrl,
          decoration: const InputDecoration(hintText: 'Ex: Poulet fermier'),
          validator: (v) => v!.isEmpty ? 'Requis' : null,
        ),
        const SizedBox(height: 16),

        // Poids + Quantité
        Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Label('Poids (kg)'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _form.weightCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: const InputDecoration(hintText: '2.0'),
                  validator: (v) => v!.isEmpty ? 'Requis' : null,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Label('Quantité'),
                const SizedBox(height: 6),
                _QuantityStepper(
                  value: _form.quantity,
                  onChanged: (v) => setState(() => _form.quantity = v),
                ),
              ],
            ),
          ),
        ]),
        const SizedBox(height: 16),

        // Prix
        const _Label('Prix unitaire (FCFA)'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _form.priceCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration:
              const InputDecoration(hintText: '3500', suffixText: 'FCFA'),
          validator: (v) => v!.isEmpty ? 'Requis' : null,
        ),
        const SizedBox(height: 16),

        // Description
        const _Label('Description (optionnel)'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _form.descCtrl,
          maxLines: 3,
          decoration:
              const InputDecoration(hintText: 'Décrivez votre produit...'),
        ),
        const SizedBox(height: 16),

        // Mode de vente
        const _Label('Mode de vente'),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: _ModeChip(
              icon: Icons.local_shipping_outlined,
              label: 'Livraison',
              isSelected: _form.deliveryAvailable,
              onTap: () => setState(
                  () => _form.deliveryAvailable = !_form.deliveryAvailable),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ModeChip(
              icon: Icons.storefront_outlined,
              label: 'Retrait ferme',
              isSelected: _form.pickupAvailable,
              onTap: () => setState(
                  () => _form.pickupAvailable = !_form.pickupAvailable),
            ),
          ),
        ]),
        const SizedBox(height: 16),

        // Certification
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(children: [
            Icon(
              _form.isCertified
                  ? Icons.verified_rounded
                  : Icons.verified_outlined,
              color: _form.isCertified
                  ? AppColors.success
                  : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Certification sanitaire vétérinaire',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.textPrimary)),
            ),
            Switch(
              value: _form.isCertified,
              activeColor: AppColors.success,
              onChanged: (v) => setState(() => _form.isCertified = v),
            ),
          ]),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    if (_form.isPickingImage) return;
    setState(() => _form.isPickingImage = true);
    try {
      final bytes = await Get.find<StorageService>().pickImage();
      if (!mounted) return;
      setState(() {
        _form.imageBytes = bytes;
        _form.isPickingImage = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _form.isPickingImage = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _form.isSaving = true);
    try {
      String? photoUrl = _form.existingPhotoUrl;
      if (_form.imageBytes != null) {
        final storage = Get.find<StorageService>();
        final productId = widget.existing?['id'] ??
            DateTime.now().millisecondsSinceEpoch.toString();
        photoUrl = await storage.uploadImage(
          bytes: _form.imageBytes!,
          path: storage.productPath(productId),
        );
      }
      await widget.ctrl.addOrUpdate(
        id: widget.existing?['id'],
        name: _form.nameCtrl.text.trim(),
        weightKg: double.tryParse(_form.weightCtrl.text) ?? 0,
        priceFcfa: double.tryParse(_form.priceCtrl.text) ?? 0,
        quantity: _form.quantity,
        isCertified: _form.isCertified,
        deliveryAvailable: _form.deliveryAvailable,
        pickupAvailable: _form.pickupAvailable,
        description: _form.descCtrl.text.trim(),
        photoUrl: photoUrl,
      );
      if (!mounted) return;
      widget.onClose();
      WoilaToast.success(
        widget.existing != null ? 'Produit mis à jour' : 'Produit ajouté',
        _form.nameCtrl.text.trim(),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _form.isSaving = false);
      WoilaToast.error('Erreur', 'Impossible d\'enregistrer le produit');
    }
  }
}

// ─────────────────────────────────────────────────────────────────
//  PAGE MOBILE
// ─────────────────────────────────────────────────────────────────
class _ProductFormPage extends StatefulWidget {
  final Map<String, dynamic>? existing;
  final StockController ctrl;

  const _ProductFormPage({required this.existing, required this.ctrl});

  @override
  State<_ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<_ProductFormPage> {
  late final _ProductFormState _form;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _form = _ProductFormState();
    _form.fillFrom(widget.existing);
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEdit ? 'Modifier le produit' : 'Ajouter un produit'),
        backgroundColor: AppColors.accent,
        foregroundColor: const Color(0xFF412402),
        actions: [
          TextButton(
            onPressed: _form.isSaving ? null : _save,
            child: _form.isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Color(0xFF412402)))
                : Text(
                    isEdit ? 'Enregistrer' : 'Ajouter',
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF412402)),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ImageDropZone(
                imageBytes: _form.imageBytes,
                existingPhotoUrl: _form.existingPhotoUrl,
                isLoading: _form.isPickingImage,
                onPick: _pickImage,
              ),
              const SizedBox(height: 16),
              const _Label('Nom du produit'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _form.nameCtrl,
                decoration:
                    const InputDecoration(hintText: 'Ex: Poulet fermier'),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Label('Poids (kg)'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _form.weightCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*')),
                        ],
                        decoration: const InputDecoration(hintText: '2.0'),
                        validator: (v) => v!.isEmpty ? 'Requis' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Label('Quantité'),
                      const SizedBox(height: 6),
                      _QuantityStepper(
                        value: _form.quantity,
                        onChanged: (v) => setState(() => _form.quantity = v),
                      ),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 14),
              const _Label('Prix unitaire (FCFA)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _form.priceCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration:
                    const InputDecoration(hintText: '3500', suffixText: 'FCFA'),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 14),
              const _Label('Description (optionnel)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _form.descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                    hintText: 'Décrivez votre produit...'),
              ),
              const SizedBox(height: 14),
              const _Label('Mode de vente'),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: _ModeChip(
                    icon: Icons.local_shipping_outlined,
                    label: 'Livraison',
                    isSelected: _form.deliveryAvailable,
                    onTap: () => setState(() =>
                        _form.deliveryAvailable = !_form.deliveryAvailable),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ModeChip(
                    icon: Icons.storefront_outlined,
                    label: 'Retrait ferme',
                    isSelected: _form.pickupAvailable,
                    onTap: () => setState(
                        () => _form.pickupAvailable = !_form.pickupAvailable),
                  ),
                ),
              ]),
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(children: [
                  Icon(
                    _form.isCertified
                        ? Icons.verified_rounded
                        : Icons.verified_outlined,
                    color: _form.isCertified
                        ? AppColors.success
                        : AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Certification sanitaire vétérinaire',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: AppColors.textPrimary),
                    ),
                  ),
                  Switch(
                    value: _form.isCertified,
                    activeColor: AppColors.success,
                    onChanged: (v) => setState(() => _form.isCertified = v),
                  ),
                ]),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    if (_form.isPickingImage) return;
    setState(() => _form.isPickingImage = true);
    try {
      final bytes = await Get.find<StorageService>().pickImage();
      if (!mounted) return;
      setState(() {
        _form.imageBytes = bytes;
        _form.isPickingImage = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _form.isPickingImage = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _form.isSaving = true);
    try {
      String? photoUrl = _form.existingPhotoUrl;
      if (_form.imageBytes != null) {
        final storage = Get.find<StorageService>();
        final productId = widget.existing?['id'] ??
            DateTime.now().millisecondsSinceEpoch.toString();
        photoUrl = await storage.uploadImage(
          bytes: _form.imageBytes!,
          path: storage.productPath(productId),
        );
      }
      await widget.ctrl.addOrUpdate(
        id: widget.existing?['id'],
        name: _form.nameCtrl.text.trim(),
        weightKg: double.tryParse(_form.weightCtrl.text) ?? 0,
        priceFcfa: double.tryParse(_form.priceCtrl.text) ?? 0,
        quantity: _form.quantity,
        isCertified: _form.isCertified,
        deliveryAvailable: _form.deliveryAvailable,
        pickupAvailable: _form.pickupAvailable,
        description: _form.descCtrl.text.trim(),
        photoUrl: photoUrl,
      );
      if (!mounted) return;
      Navigator.pop(context);
      WoilaToast.success(
        widget.existing != null ? 'Produit mis à jour' : 'Produit ajouté',
        _form.nameCtrl.text.trim(),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _form.isSaving = false);
      WoilaToast.error('Erreur', 'Impossible d\'enregistrer le produit');
    }
  }
}

// ─────────────────────────────────────────────────────────────────
//  WIDGETS RÉUTILISABLES
// ─────────────────────────────────────────────────────────────────

// Zone de glisser-déposer / clic image
class _ImageDropZone extends StatelessWidget {
  final Uint8List? imageBytes;
  final String? existingPhotoUrl;
  final bool isLoading;
  final VoidCallback onPick;

  const _ImageDropZone({
    required this.imageBytes,
    required this.existingPhotoUrl,
    required this.isLoading,
    required this.onPick,
  });

  bool get _hasImage =>
      imageBytes != null ||
      (existingPhotoUrl != null && existingPhotoUrl!.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPick,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hasImage ? AppColors.divider : AppColors.divider,
            style: _hasImage ? BorderStyle.solid : BorderStyle.solid,
          ),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primary, strokeWidth: 2),
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  // Image
                  if (imageBytes != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.memory(imageBytes!, fit: BoxFit.cover),
                    )
                  else if (existingPhotoUrl != null &&
                      existingPhotoUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(existingPhotoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _emptyState()),
                    )
                  else
                    _emptyState(),

                  // Overlay si image présente
                  if (_hasImage)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        color: Colors.transparent,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onPick,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.35),
                                  ],
                                ),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.camera_alt_outlined,
                                            color: Colors.white, size: 16),
                                        SizedBox(width: 6),
                                        Text('Changer la photo',
                                            style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 12,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _emptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.add_a_photo_outlined,
              color: AppColors.primary, size: 26),
        ),
        const SizedBox(height: 10),
        const Text('Cliquez pour ajouter une photo',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        const Text('JPG ou PNG · max 5 MB',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: AppColors.textSecondary)),
      ],
    );
  }
}

// Stepper quantité — flèches haut/bas
class _QuantityStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _QuantityStepper({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(children: [
        // Bouton moins
        InkWell(
          onTap: value > 0 ? () => onChanged(value - 1) : null,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          ),
          child: SizedBox(
            width: 42,
            height: 48,
            child: Icon(
              Icons.remove_rounded,
              size: 18,
              color: value > 0
                  ? AppColors.primary
                  : AppColors.textSecondary.withValues(alpha: 0.3),
            ),
          ),
        ),

        // Valeur
        Expanded(
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary),
          ),
        ),

        // Bouton plus
        InkWell(
          onTap: () => onChanged(value + 1),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          child: const SizedBox(
            width: 42,
            height: 48,
            child: Icon(
              Icons.add_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ),
        ),
      ]),
    );
  }
}

// Chip mode de vente
class _ModeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16,
                color:
                    isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// Label de champ
class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary));
  }
}

class _DialogField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final TextInputType? keyboardType;

  const _DialogField({
    required this.ctrl,
    required this.label,
    required this.hint,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _Label(label),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        decoration: InputDecoration(hintText: hint),
      ),
    ]);
  }
}
