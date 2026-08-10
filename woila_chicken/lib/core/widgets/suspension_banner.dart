import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

class SuspensionBanner extends StatelessWidget {
  const SuspensionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    final firestore = Get.find<FirestoreService>();

    return FutureBuilder<Map<String, dynamic>?>(
      future: firestore.getFarmByOwner(auth.uid),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox.shrink();
        final isSuspended =
            snap.data?['isSuspended'] as bool? ?? false;
        if (!isSuspended) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
          color: AppColors.error,
          child: Row(children: [
            const Icon(Icons.block_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Compte suspendu — Vos produits ne sont plus visibles. '
                'Contactez l\'admin.',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () async {
                final uri = Uri.parse(
                    'mailto:woila.chicken.cm@gmail.com'
                    '?subject=Suspension%20de%20compte');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Contacter',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.error)),
              ),
            ),
          ]),
        );
      },
    );
  }
}