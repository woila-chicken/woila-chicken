import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/product.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/widgets/woila_toast.dart';
import 'order_confirmation_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';

enum MobileOperator { orange, mtn }

class CheckoutScreen extends StatefulWidget {
  final Product product;
  final int quantity;
  final bool wantsDelivery;

  const CheckoutScreen({
    super.key,
    required this.product,
    required this.quantity,
    required this.wantsDelivery,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _quartierCtrl = TextEditingController();
  final _villeCtrl = TextEditingController(text: 'Garoua');
  final _indicationCtrl = TextEditingController();
  final _momoCtrl = TextEditingController();

  MobileOperator _operator = MobileOperator.orange;
  bool _isProcessing = false;

  double get _deliveryFee => widget.wantsDelivery ? 500 : 0;
  double get _subtotal => widget.product.pricefcfa * widget.quantity;
  double get _total => _subtotal + _deliveryFee;

  String _formatPrice(double p) =>
      '${p.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]} ',
          )} FCFA';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _quartierCtrl.dispose();
    _villeCtrl.dispose();
    _indicationCtrl.dispose();
    _momoCtrl.dispose();
    super.dispose();
  }

Future<void> _pay() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _isProcessing = true);

  try {
    final auth = Get.find<AuthService>();
    final firestore = Get.find<FirestoreService>();

    debugPrint('uid: ${auth.uid}');
    debugPrint('product.farmId: ${widget.product.farmId}');
    debugPrint('product.id: ${widget.product.id}');
    debugPrint('total: $_total');

    if (auth.uid.isEmpty) {
      WoilaToast.error('Erreur', 'Vous devez être connecté');
      setState(() => _isProcessing = false);
      return;
    }

    final orderId = await firestore.createOrder({
      'clientId': auth.uid,
      'productPhotoUrl': widget.product.imageUrl ?? '',
      'clientName': _nameCtrl.text.trim().isEmpty
          ? 'Client'
          : _nameCtrl.text.trim(),
      'clientPhone': _phoneCtrl.text.trim(),
      'farmId': widget.product.farmId,
      'farmName': widget.product.farmName,
      'productId': widget.product.id,
      'productName':
          '${widget.product.name} ${widget.product.weightKg}kg',
      'quantity': widget.quantity,
      'priceFcfa': widget.product.pricefcfa,
      'deliveryFee': _deliveryFee,
      'total': _total,
      'isDelivery': widget.wantsDelivery,
      'address': widget.wantsDelivery
          ? '${_quartierCtrl.text}, ${_villeCtrl.text}'
          : '',
      'phone': _phoneCtrl.text.trim(),
      'operator':
          _operator == MobileOperator.orange ? 'orange' : 'mtn',
      'momoNumber': _momoCtrl.text.trim(),
    });

    debugPrint('orderId obtenu: $orderId');

    // Décrémenter le stock
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product.id)
          .update({
        'quantity': FieldValue.increment(-widget.quantity),
      });
    } catch (e) {
      debugPrint('Erreur décrémentation stock (non bloquant): $e');
    }

    if (!mounted) return;
    setState(() => _isProcessing = false);

    Get.off(() => OrderConfirmationScreen(
          product: widget.product,
          quantity: widget.quantity,
          total: _total,
          wantsDelivery: widget.wantsDelivery,
          orderRef: orderId,
        ));
  } catch (e) {
    debugPrint('Erreur _pay: $e');
    if (!mounted) return;
    setState(() => _isProcessing = false);
    WoilaToast.error(
      'Impossible de passer la commande',
      e.toString().length > 60
          ? '${e.toString().substring(0, 60)}...'
          : e.toString(),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Finaliser la commande')),
      body: ResponsiveLayout(
        desktop: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: _buildBody(isDesktop: true),
          ),
        ),
        mobile: _buildBody(isDesktop: false),
      ),
    );
  }

  Widget _buildBody({required bool isDesktop}) {
    return Form(
      key: _formKey,
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(children: [
                      if (widget.wantsDelivery) _AddressSection(),
                      const SizedBox(height: 16),
                      _PaymentSection(
                        operator: _operator,
                        momoCtrl: _momoCtrl,
                        onOperatorChanged: (op) =>
                            setState(() => _operator = op),
                      ),
                    ]),
                  ),
                ),
                Container(width: 1, color: AppColors.divider),
                Expanded(
                  flex: 4,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(children: [
                      _SummarySection(
                        product: widget.product,
                        quantity: widget.quantity,
                        deliveryFee: _deliveryFee,
                        total: _total,
                        formatPrice: _formatPrice,
                        wantsDelivery: widget.wantsDelivery,
                      ),
                      const SizedBox(height: 16),
                      _EscrowBadge(),
                      const SizedBox(height: 16),
                      _PayButton(
                        total: _total,
                        formatPrice: _formatPrice,
                        isProcessing: _isProcessing,
                        onPay: _pay,
                      ),
                    ]),
                  ),
                ),
              ],
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                if (widget.wantsDelivery) _AddressSection(),
                const SizedBox(height: 16),
                _PaymentSection(
                  operator: _operator,
                  momoCtrl: _momoCtrl,
                  onOperatorChanged: (op) =>
                      setState(() => _operator = op),
                ),
                const SizedBox(height: 16),
                _SummarySection(
                  product: widget.product,
                  quantity: widget.quantity,
                  deliveryFee: _deliveryFee,
                  total: _total,
                  formatPrice: _formatPrice,
                  wantsDelivery: widget.wantsDelivery,
                ),
                const SizedBox(height: 16),
                _EscrowBadge(),
                const SizedBox(height: 20),
                _PayButton(
                  total: _total,
                  formatPrice: _formatPrice,
                  isProcessing: _isProcessing,
                  onPay: _pay,
                ),
              ]),
            ),
    );
  }
}

// ─── Section adresse ─────────────────────────────────────────────
class _AddressSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _CheckoutCard(
      icon: Icons.map_outlined,
      title: 'Adresse de livraison',
      child: Column(children: [
        _CheckoutField(label: 'Nom complet', hint: 'Ex: Amadou Diallo',
            validator: (v) => v!.isEmpty ? 'Requis' : null),
        const SizedBox(height: 12),
        _CheckoutField(
          label: 'Téléphone',
          hint: '+237 6XX XXX XXX',
          keyboardType: TextInputType.phone,
          validator: (v) => v!.isEmpty ? 'Requis' : null,
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: _CheckoutField(
              label: 'Quartier',
              hint: 'Ex: Marché central',
              validator: (v) => v!.isEmpty ? 'Requis' : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _CheckoutField(
              label: 'Ville',
              hint: 'Garoua',
              validator: (v) => v!.isEmpty ? 'Requis' : null,
            ),
          ),
        ]),
        const SizedBox(height: 12),
        const _CheckoutField(
          label: 'Indication (optionnel)',
          hint: 'Près de la mosquée, couleur de la maison...',
          maxLines: 2,
        ),
      ]),
    );
  }
}

// ─── Section paiement ─────────────────────────────────────────────
class _PaymentSection extends StatelessWidget {
  final MobileOperator operator;
  final TextEditingController momoCtrl;
  final ValueChanged<MobileOperator> onOperatorChanged;

  const _PaymentSection({
    required this.operator,
    required this.momoCtrl,
    required this.onOperatorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _CheckoutCard(
      icon: Icons.phone_android_outlined,
      title: 'Paiement Mobile Money',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Choix opérateur
          Row(children: [
            Expanded(
              child: _OperatorCard(
                label: 'Orange Money',
                color: const Color(0xFFFF6600),
                isSelected: operator == MobileOperator.orange,
                onTap: () => onOperatorChanged(MobileOperator.orange),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _OperatorCard(
                label: 'MTN MoMo',
                color: const Color(0xFFFFCC00),
                isSelected: operator == MobileOperator.mtn,
                onTap: () => onOperatorChanged(MobileOperator.mtn),
              ),
            ),
          ]),
          const SizedBox(height: 16),

          // Numéro MoMo
          _CheckoutField(
            label: operator == MobileOperator.orange
                ? 'Numéro Orange Money'
                : 'Numéro MTN MoMo',
            hint: '+237 6XX XXX XXX',
            controller: momoCtrl,
            keyboardType: TextInputType.phone,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Numéro requis';
              if (v.length < 9) return 'Numéro invalide';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Étapes
          const Text('Comment ça marche',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          const _StepRow(num: '1', text: 'Entrez votre numéro et appuyez sur Payer'),
          const SizedBox(height: 6),
          const _StepRow(num: '2', text: 'Vous recevrez une notification sur votre téléphone'),
          const SizedBox(height: 6),
          const _StepRow(num: '3', text: 'Validez le paiement avec votre code PIN'),
        ],
      ),
    );
  }
}

class _OperatorCard extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _OperatorCard({
    required this.label,
    required this.color,
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
          color: isSelected ? color.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? color : AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String num;
  final String text;
  const _StepRow({required this.num, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(num,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.textSecondary)),
        ),
      ],
    );
  }
}

// ─── Section récapitulatif ────────────────────────────────────────
class _SummarySection extends StatelessWidget {
  final Product product;
  final int quantity;
  final double deliveryFee;
  final double total;
  final String Function(double) formatPrice;
  final bool wantsDelivery;

  const _SummarySection({
    required this.product,
    required this.quantity,
    required this.deliveryFee,
    required this.total,
    required this.formatPrice,
    required this.wantsDelivery,
  });

  @override
  Widget build(BuildContext context) {
    return _CheckoutCard(
      icon: Icons.receipt_long_outlined,
      title: 'Récapitulatif',
      child: Column(children: [
        _SummaryRow(
          label: '${product.name} × $quantity',
          value: formatPrice(product.pricefcfa * quantity),
        ),
        if (wantsDelivery) ...[
          const SizedBox(height: 8),
          _SummaryRow(label: 'Frais de livraison', value: formatPrice(deliveryFee)),
        ],
        const Divider(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total à payer',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            Text(formatPrice(total),
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
          ],
        ),
      ]),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.textSecondary)),
        Text(value,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      ],
    );
  }
}

// ─── Badge séquestre ──────────────────────────────────────────────
class _EscrowBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield_outlined, color: AppColors.success, size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Paiement sécurisé — votre argent est libéré à l\'éleveur uniquement après votre confirmation de réception.',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: AppColors.success),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bouton payer ─────────────────────────────────────────────────
class _PayButton extends StatelessWidget {
  final double total;
  final String Function(double) formatPrice;
  final bool isProcessing;
  final VoidCallback onPay;

  const _PayButton({
    required this.total,
    required this.formatPrice,
    required this.isProcessing,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isProcessing ? null : onPay,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 18),
                  const SizedBox(width: 8),
                  Text('Payer ${formatPrice(total)}',
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                ],
              ),
      ),
    );
  }
}

// ─── Card conteneur générique ─────────────────────────────────────
class _CheckoutCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _CheckoutCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ─── Champ formulaire réutilisable ────────────────────────────────
class _CheckoutField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  const _CheckoutField({
    required this.label,
    required this.hint,
    this.controller,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
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
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}