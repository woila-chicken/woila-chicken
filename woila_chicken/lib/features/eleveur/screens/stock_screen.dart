import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';

class StockItem {
  final String id;
  String name;
  double weightKg;
  double priceFcfa;
  int quantity;
  bool isCertified;

  StockItem({
    required this.id,
    required this.name,
    required this.weightKg,
    required this.priceFcfa,
    required this.quantity,
    required this.isCertified,
  });
}

class StockController extends GetxController {
  final items = <StockItem>[
    StockItem(id: 's1', name: 'Poulet fermier 2kg',  weightKg: 2.0, priceFcfa: 3500, quantity: 8,  isCertified: true),
    StockItem(id: 's2', name: 'Gros poulet 2.5kg',   weightKg: 2.5, priceFcfa: 4200, quantity: 3,  isCertified: true),
    StockItem(id: 's3', name: 'Poulet local 1.8kg',  weightKg: 1.8, priceFcfa: 2800, quantity: 1,  isCertified: false),
    StockItem(id: 's4', name: 'Poulet fermier XL',   weightKg: 3.0, priceFcfa: 5100, quantity: 5,  isCertified: true),
  ].obs;

  void deleteItem(String id) => items.removeWhere((i) => i.id == id);

  void addOrUpdate(StockItem item) {
    final idx = items.indexWhere((i) => i.id == item.id);
    if (idx >= 0) {
      items[idx] = item;
    } else {
      items.add(item);
    }
    items.refresh();
  }
}

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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(context, ctrl, null),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Ajouter',
            style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
      ),
      body: ResponsiveLayout(
        desktop: _buildDesktop(context, ctrl),
        mobile: _buildMobile(context, ctrl),
      ),
    );
  }

  Widget _buildDesktop(BuildContext context, StockController ctrl) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: _buildList(context, ctrl),
        ),
      ),
    );
  }

  Widget _buildMobile(BuildContext context, StockController ctrl) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _buildList(context, ctrl),
    );
  }

  Widget _buildList(BuildContext context, StockController ctrl) {
    return Obx(() {
      if (ctrl.items.isEmpty) {
        return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.inventory_2_outlined,
                size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            const Text('Aucun produit en stock',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: AppColors.textSecondary)),
          ]),
        );
      }
      return ListView.separated(
        itemCount: ctrl.items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final item = ctrl.items[i];
          final isLow = item.quantity <= 2;
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isLow
                    ? AppColors.warning.withOpacity(0.5)
                    : AppColors.divider,
              ),
            ),
            child: Row(children: [
              // Image
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Image.asset('assets/images/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          const Center(child: Icon(Icons.set_meal_rounded, color: AppColors.primary, size: 24)),
                )),
              ),
              const SizedBox(width: 14),
              // Infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 3),
                    Row(children: [
                      Text('${item.priceFcfa.toInt()} FCFA',
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                      const SizedBox(width: 10),
                      if (item.isCertified)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('✓ Certifié',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600)),
                        ),
                    ]),
                    const SizedBox(height: 3),
                    Row(children: [
                      Icon(
                        isLow
                            ? Icons.warning_amber_outlined
                            : Icons.inventory_2_outlined,
                        size: 13,
                        color: isLow
                            ? AppColors.warning
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Stock : ${item.quantity}${isLow ? ' — Faible' : ''}',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: isLow
                                ? AppColors.warning
                                : AppColors.textSecondary,
                            fontWeight: isLow ? FontWeight.w600 : FontWeight.normal),
                      ),
                    ]),
                  ],
                ),
              ),
              // Actions
              Column(children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      color: AppColors.primary, size: 20),
                  onPressed: () => _showAddEditDialog(context, ctrl, item),
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

  void _showAddEditDialog(
      BuildContext context, StockController ctrl, StockItem? existing) {
    final isEdit = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final weightCtrl = TextEditingController(
        text: existing?.weightKg.toString() ?? '');
    final priceCtrl = TextEditingController(
        text: existing?.priceFcfa.toInt().toString() ?? '');
    final qtyCtrl = TextEditingController(
        text: existing?.quantity.toString() ?? '');
    bool certified = existing?.isCertified ?? false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isEdit ? 'Modifier le produit' : 'Ajouter un produit',
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _DialogField(ctrl: nameCtrl, label: 'Nom du produit',
                  hint: 'Ex: Poulet fermier'),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _DialogField(
                    ctrl: weightCtrl, label: 'Poids (kg)',
                    hint: '2.0',
                    keyboardType: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: _DialogField(
                    ctrl: qtyCtrl, label: 'Quantité',
                    hint: '10',
                    keyboardType: TextInputType.number)),
              ]),
              const SizedBox(height: 12),
              _DialogField(ctrl: priceCtrl, label: 'Prix (FCFA)',
                  hint: '3500',
                  keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              Row(children: [
                Switch(
                  value: certified,
                  activeColor: AppColors.success,
                  onChanged: (v) => setS(() => certified = v),
                ),
                const SizedBox(width: 8),
                const Text('Certifié sanitaire',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: AppColors.textPrimary)),
              ]),
            ]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler',
                  style: TextStyle(color: AppColors.textSecondary,
                      fontFamily: 'Poppins')),
            ),
            ElevatedButton(
              onPressed: () {
                ctrl.addOrUpdate(StockItem(
                  id: existing?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameCtrl.text,
                  weightKg: double.tryParse(weightCtrl.text) ?? 0,
                  priceFcfa: double.tryParse(priceCtrl.text) ?? 0,
                  quantity: int.tryParse(qtyCtrl.text) ?? 0,
                  isCertified: certified,
                ));
                Navigator.pop(ctx);
              },
              child: Text(isEdit ? 'Enregistrer' : 'Ajouter',
                  style: const TextStyle(fontFamily: 'Poppins')),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, StockController ctrl, StockItem item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer ce produit ?',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        content: Text('${item.name} sera retiré de votre catalogue.',
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
                style: TextStyle(color: AppColors.textSecondary,
                    fontFamily: 'Poppins')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            onPressed: () {
              ctrl.deleteItem(item.id);
              Navigator.pop(context);
            },
            child: const Text('Supprimer',
                style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
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
      Text(label,
          style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary)),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        decoration: InputDecoration(hintText: hint),
      ),
    ]);
  }
}