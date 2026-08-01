import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/widgets/woila_toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class AdminDisputesScreen extends StatelessWidget {
  const AdminDisputesScreen({super.key});

  Future<List<Map<String, dynamic>?>> _loadDisputeParties(
      Map<String, dynamic> dispute) async {
    final clientId = dispute['clientId'] as String? ?? '';
    final farmId = dispute['farmId'] as String? ?? '';

    Map<String, dynamic>? client;
    Map<String, dynamic>? farm;

    if (clientId.isNotEmpty) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(clientId)
          .get();
      if (doc.exists) client = doc.data();
    }

    if (farmId.isNotEmpty) {
      final doc = await FirebaseFirestore.instance
          .collection('farms')
          .doc(farmId)
          .get();
      if (doc.exists) farm = doc.data();
    }

    // Si pas de farmId direct, chercher via orderId
    if (farm == null) {
      final orderId = dispute['orderId'] as String? ?? '';
      if (orderId.isNotEmpty) {
        final orderDoc = await FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .get();
        if (orderDoc.exists) {
          final fid = orderDoc.data()?['farmId'] as String? ?? '';
          if (fid.isNotEmpty) {
            final farmDoc = await FirebaseFirestore.instance
                .collection('farms')
                .doc(fid)
                .get();
            if (farmDoc.exists) farm = farmDoc.data();
          }
          // Charger client depuis orderId si pas trouvé
          if (client == null) {
            final cid = orderDoc.data()?['clientId'] as String? ?? '';
            if (cid.isNotEmpty) {
              final clientDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(cid)
                  .get();
              if (clientDoc.exists) client = clientDoc.data();
            }
          }
        }
      }
    }

    String? farmOwnerEmail;
    final ownerId = farm?['ownerId'] as String? ?? '';
    if (ownerId.isNotEmpty) {
      final ownerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(ownerId)
          .get();
      if (ownerDoc.exists) {
        farmOwnerEmail = ownerDoc.data()?['email'] as String?;
        // Fusionner dans farm
        farm = {
          ...?farm,
          'email': farmOwnerEmail ?? '',
        };
      }
    }
    return [client, farm];
  }

  @override
  Widget build(BuildContext context) {
    final firestore = Get.find<FirestoreService>();
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: firestore.getAllDisputes(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        final disputes = snap.data ?? [];
        final openCount = disputes.where((d) => d['status'] == 'open').length;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Gestion des litiges'),
            backgroundColor: AppColors.adminColor,
            automaticallyImplyLeading: true,
            actions: [
              if (openCount > 0)
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('$openCount ouverts',
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
            ],
          ),
          body: ResponsiveLayout(
            desktop: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: _buildList(context, disputes, firestore),
              ),
            ),
            mobile: _buildList(context, disputes, firestore),
          ),
        );
      },
    );
  }

  Widget _buildList(BuildContext context, List<Map<String, dynamic>> disputes,
      FirestoreService firestore) {
    if (disputes.isEmpty) {
      return const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.gavel_rounded, size: 64, color: AppColors.textSecondary),
          SizedBox(height: 12),
          Text('Aucun litige',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  color: AppColors.textSecondary)),
          SizedBox(height: 6),
          Text('Tout va bien pour le moment',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.textSecondary)),
        ]),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: disputes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final d = disputes[i];
        final status = d['status'] as String? ?? 'open';
        final isOpen = status == 'open';
        final isInProgress = status == 'inProgress';

        Color statusColor;
        String statusLabel;
        switch (status) {
          case 'open':
            statusColor = AppColors.error;
            statusLabel = 'Ouvert';
            break;
          case 'inProgress':
            statusColor = AppColors.warning;
            statusLabel = 'En cours';
            break;
          default:
            statusColor = AppColors.success;
            statusLabel = 'Résolu';
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isOpen
                  ? AppColors.error.withValues(alpha: 0.4)
                  : AppColors.divider,
              width: isOpen ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Row(children: [
                Text(
                  '#${d['orderId'] ?? ''}',
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    d['type'] as String? ?? 'Autre',
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(statusLabel,
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: statusColor)),
                ),
              ]),
              const SizedBox(height: 10),

              // Détails
              _DetailRow(
                  icon: Icons.person_outline,
                  text: d['clientId'] as String? ?? ''),
              const SizedBox(height: 4),
              _DetailRow(
                  icon: Icons.calendar_today_outlined,
                  text: _formatDate(d['createdAt'])),
              const SizedBox(height: 8),

              // Description
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  d['description'] as String? ?? '',
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppColors.textSecondary),
                ),
              ),

              // Actions
              if (isOpen || isInProgress) ...[
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await firestore.resolveDispute(d['id']);
                        WoilaToast.success('Litige résolu',
                            'Le litige a été marqué comme résolu');
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: const Text('Résoudre',
                          style:
                              TextStyle(fontFamily: 'Poppins', fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showContactDialog(context, d),
                      icon: const Icon(Icons.chat_outlined, size: 16),
                      label: const Text('Contacter',
                          style:
                              TextStyle(fontFamily: 'Poppins', fontSize: 12)),
                    ),
                  ),
                  if (isOpen) ...[
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () async {
                        await Get.find<FirestoreService>()
                            .getAllDisputes()
                            .first
                            .then((_) async {
                          await FirestoreService().resolveDispute(d['id']);
                        });
                      },
                      icon: const Icon(Icons.pending_actions_outlined,
                          color: AppColors.warning),
                      tooltip: 'Marquer en cours',
                    ),
                  ],
                ]),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showContactDialog(BuildContext context, Map<String, dynamic> dispute) {
    final firestore = Get.find<FirestoreService>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Contacter les parties',
            style:
                TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        content: FutureBuilder<List<Map<String, dynamic>?>>(
          future: _loadDisputeParties(dispute),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final client = snap.data?[0];
            final farm = snap.data?[1];
            return SingleChildScrollView(
              // ← évite l'overflow
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ContactTile(
                    icon: Icons.person_outline,
                    title: client?['name'] as String? ?? 'Client inconnu',
                    phone: client?['phone'] as String? ?? '',
                    email: client?['email'] as String? ?? '',
                    role: 'Client',
                    dispute: dispute,
                  ),
                  const SizedBox(height: 10),
                  _ContactTile(
                    icon: Icons.store_outlined,
                    title: farm?['name'] as String? ?? 'Ferme inconnue',
                    phone: farm?['phone'] as String? ?? '',
                    email: farm?['email'] as String? ?? '',
                    role: 'Éleveur',
                    dispute: dispute,
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer',
                style: TextStyle(
                    fontFamily: 'Poppins', color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final dt = (timestamp as dynamic).toDate();
      const months = [
        'jan',
        'fév',
        'mar',
        'avr',
        'mai',
        'juin',
        'juil',
        'août',
        'sep',
        'oct',
        'nov',
        'déc'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return '';
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 14, color: AppColors.textSecondary),
      const SizedBox(width: 6),
      Text(text,
          style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: AppColors.textSecondary)),
    ]);
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String phone;
  final String email;
  final String role;
  final Map<String, dynamic> dispute;
  

  const _ContactTile({
    required this.icon,
    required this.title,
    required this.phone,
    required this.email,
    required this.role,
    required this.dispute,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => _launchPhone(context, phone),
                    child: Row(children: [
                      const Icon(Icons.phone_outlined,
                          size: 13, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text(phone,
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: AppColors.success,
                              decoration: TextDecoration.underline)),
                    ]),
                  ),
                ],
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => _launchEmail(context, email, role, dispute),
                    child: Row(children: [
                      const Icon(Icons.email_outlined,
                          size: 13, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(email,
                            style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: AppColors.primary,
                                decoration: TextDecoration.underline),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(role,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Future<void> _launchPhone(BuildContext context, String phone) async {
    final clean = phone.replaceAll(' ', '');
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // PC — copier dans le presse-papier
      await Clipboard.setData(ClipboardData(text: phone));
      if (context.mounted) {
        WoilaToast.info('Copié', '$phone copié dans le presse-papier');
      }
    }
  }

  Future<void> _launchEmail(BuildContext context, String email, String role,
      Map<String, dynamic> dispute) async {
    final orderRef = dispute['orderId'] as String? ?? '';

    String subject;
    String body;

    if (role == 'Client') {
      subject = 'Woïla Chicken — Votre litige #$orderRef';
      body = '''Bonjour,

Nous avons bien reçu votre signalement concernant la commande #$orderRef.

Notre équipe a examiné votre dossier et revient vers vous dans les plus brefs délais.

Si vous avez des informations supplémentaires à nous communiquer, n'hésitez pas à répondre à cet email.

Cordialement,
L'équipe Woïla Chicken
woila.chicken.cm@gmail.com''';
    } else {
      subject = 'Woïla Chicken — Litige signalé #$orderRef';
      body = '''Bonjour,

Un litige a été signalé concernant une commande passée sur votre ferme (réf: #$orderRef).

Notre équipe examine actuellement la situation et vous contactera pour trouver une résolution.

Merci de bien vouloir conserver toutes les informations relatives à cette commande.

Cordialement,
L'équipe Woïla Chicken
woila.chicken.cm@gmail.com''';
    }

    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=${Uri.encodeComponent(subject)}'
          '&body=${Uri.encodeComponent(body)}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      await Clipboard.setData(ClipboardData(text: '$subject\n\n$body'));
      if (context.mounted) {
        WoilaToast.info('Copié', 'Email copié dans le presse-papier');
      }
    }
  }
}
