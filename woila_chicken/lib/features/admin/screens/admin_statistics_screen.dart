import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kpi_card.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/services/firestore_service.dart';

class AdminStatisticsScreen extends StatelessWidget {
  const AdminStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = Get.find<FirestoreService>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Statistiques marché'),
        backgroundColor: AppColors.adminColor,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: firestore.getAdminStats(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          final stats = snap.data ?? {};
          return ResponsiveLayout(
            desktop: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: _buildContent(context, stats, isDesktop: true),
              ),
            ),
            mobile: _buildContent(context, stats, isDesktop: false),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context,
      Map<String, dynamic> stats, {required bool isDesktop}) {
    final totalCommission =
        (stats['totalCommission'] as double? ?? 0.0);
    final activeFarms = stats['activeFarms'] as int? ?? 0;
    final openDisputes = stats['openDisputes'] as int? ?? 0;
    final totalOrders = stats['totalOrders'] as int? ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── KPIs ────────────────────────────────────────────────
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isDesktop ? 4 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: isDesktop ? 1.2 : 1.0,
            children: [
              WoilaKpiCard(
                value: totalCommission.toStringAsFixed(0),
                unit: 'FCFA',
                label: 'Commissions totales',
                icon: Icons.account_balance_wallet_rounded,
                color: AppColors.success,
                trend: KpiTrend.up,
                trendLabel: 'ce mois',
              ),
              WoilaKpiCard(
                value: '$totalOrders',
                unit: 'commandes',
                label: 'Total commandes',
                icon: Icons.swap_horiz_rounded,
                color: AppColors.primary,
                trend: KpiTrend.up,
                trendLabel: 'total',
              ),
              WoilaKpiCard(
                value: '$activeFarms',
                unit: 'fermes',
                label: 'Fermes actives',
                icon: Icons.store_rounded,
                color: AppColors.warning,
                trend: KpiTrend.neutral,
                trendLabel: 'actives',
              ),
              WoilaKpiCard(
                value: '$openDisputes',
                unit: 'litiges',
                label: 'Litiges ouverts',
                icon: Icons.gavel_rounded,
                color: AppColors.error,
                trend: openDisputes > 0
                    ? KpiTrend.down
                    : KpiTrend.neutral,
                trendLabel: openDisputes > 0 ? 'attention' : 'ok',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Graphique commandes par mois ─────────────────────────
          _StatCard(
            title: 'Commissions mensuelles (FCFA)',
            icon: Icons.bar_chart_outlined,
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: Get.find<FirestoreService>().getAllOrders(),
              builder: (context, snap) {
                final orders = snap.data ?? [];
                final monthlyData =
                    _buildMonthlyData(orders);
                return _BarChart(data: monthlyData);
              },
            ),
          ),
          const SizedBox(height: 16),

          // ── Indicateurs ──────────────────────────────────────────
          isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: _TopFarmes(firestore:
                            Get.find<FirestoreService>())),
                    const SizedBox(width: 16),
                    Expanded(child: _MarketIndicators(stats: stats)),
                  ],
                )
              : Column(children: [
                  _TopFarmes(
                      firestore: Get.find<FirestoreService>()),
                  const SizedBox(height: 16),
                  _MarketIndicators(stats: stats),
                ]),
        ],
      ),
    );
  }

  List<_BarData> _buildMonthlyData(
      List<Map<String, dynamic>> orders) {
    final Map<int, double> monthlyCommission = {};
    for (final order in orders) {
      try {
        final dt = (order['createdAt'] as dynamic).toDate();
        final month = dt.month;
        final commission =
            (order['commission'] as num?)?.toDouble() ?? 0;
        monthlyCommission[month] =
            (monthlyCommission[month] ?? 0) + commission;
      } catch (_) {}
    }

    const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun'];
    final now = DateTime.now();
    final result = <_BarData>[];
    double maxVal = 1;

    for (int i = 5; i >= 0; i--) {
      final month = ((now.month - i - 1) % 12) + 1;
      final val = monthlyCommission[month] ?? 0;
      if (val > maxVal) maxVal = val;
    }

    for (int i = 5; i >= 0; i--) {
      final month = ((now.month - i - 1) % 12) + 1;
      final val = monthlyCommission[month] ?? 0;
      result.add(_BarData(
        label: months[5 - i],
        value: maxVal > 0 ? val / maxVal : 0,
        rawValue: val,
      ));
    }
    return result;
  }
}

// ─── Top fermes ────────────────────────────────────────────────────
class _TopFarmes extends StatelessWidget {
  final FirestoreService firestore;
  const _TopFarmes({required this.firestore});

  @override
  Widget build(BuildContext context) {
    return _StatCard(
      title: 'Top fermes ce mois',
      icon: Icons.leaderboard_outlined,
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestore.getAllFarms(),
        builder: (context, snap) {
          final farms = snap.data ?? [];
          final verified = farms
              .where((f) => f['isVerified'] == true)
              .toList();

          if (verified.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Aucune ferme vérifiée',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: AppColors.textSecondary)),
              ),
            );
          }

          return Column(
            children: verified.take(3).toList().asMap().entries.map((e) {
              final rank = e.key + 1;
              final farm = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _rankColor(rank).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text('#$rank',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _rankColor(rank))),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(farm['name'] as String? ?? '',
                            style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary)),
                        Text(
                          '${farm['rating'] ?? 0} ★ · ${farm['totalRatings'] ?? 0} avis',
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ]),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Color _rankColor(int rank) {
    switch (rank) {
      case 1: return AppColors.accent;
      case 2: return AppColors.textSecondary;
      case 3: return const Color(0xFFCD7F32);
      default: return AppColors.textSecondary;
    }
  }
}

// ─── Indicateurs marché ────────────────────────────────────────────
class _MarketIndicators extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _MarketIndicators({required this.stats});

  @override
  Widget build(BuildContext context) {
    final totalOrders = stats['totalOrders'] as int? ?? 0;
    final activeFarms = stats['activeFarms'] as int? ?? 0;
    final openDisputes = stats['openDisputes'] as int? ?? 0;
    final totalCommission =
        (stats['totalCommission'] as double? ?? 0.0);

    final deliveryRate = totalOrders > 0
        ? '${((totalOrders - openDisputes) / totalOrders * 100).toStringAsFixed(0)} %'
        : '— %';

    return _StatCard(
      title: 'Indicateurs clés',
      icon: Icons.insights_outlined,
      child: Column(children: [
        _IndicatorRow(
          label: 'Commissions totales',
          value: '${totalCommission.toStringAsFixed(0)} FCFA',
          trend: '',
          isUp: true,
        ),
        const SizedBox(height: 10),
        _IndicatorRow(
          label: 'Fermes actives',
          value: '$activeFarms fermes',
          trend: '',
          isUp: true,
        ),
        const SizedBox(height: 10),
        _IndicatorRow(
          label: 'Total commandes',
          value: '$totalOrders',
          trend: '',
          isUp: true,
        ),
        const SizedBox(height: 10),
        _IndicatorRow(
          label: 'Taux de livraison',
          value: deliveryRate,
          trend: '',
          isUp: openDisputes == 0,
        ),
        const SizedBox(height: 10),
        _IndicatorRow(
          label: 'Litiges ouverts',
          value: '$openDisputes',
          trend: openDisputes == 0 ? 'ok' : 'attention',
          isUp: openDisputes == 0,
        ),
      ]),
    );
  }
}

// ─── Graphique barres ──────────────────────────────────────────────
class _BarData {
  final String label;
  final double value;
  final double rawValue;
  const _BarData({
    required this.label,
    required this.value,
    required this.rawValue,
  });
}

class _BarChart extends StatelessWidget {
  final List<_BarData> data;
  const _BarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('Aucune donnée disponible',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppColors.textSecondary)),
        ),
      );
    }
    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((d) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (d.rawValue > 0)
                    Text(
                      '${d.rawValue.toStringAsFixed(0)} F',
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 8,
                          color: AppColors.textSecondary),
                    ),
                  const SizedBox(height: 4),
                  Container(
                    height: (d.value * 110).clamp(4.0, 110.0),
                    decoration: BoxDecoration(
                      color: d.value >= 0.9
                          ? AppColors.primary
                          : AppColors.primary
                              .withOpacity(0.3 + d.value * 0.4),
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(d.label,
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: AppColors.textSecondary)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Widgets utilitaires ──────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _StatCard({
    required this.title,
    required this.icon,
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

class _IndicatorRow extends StatelessWidget {
  final String label;
  final String value;
  final String trend;
  final bool isUp;

  const _IndicatorRow({
    required this.label,
    required this.value,
    required this.trend,
    required this.isUp,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Text(label,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: AppColors.textSecondary)),
      ),
      Text(value,
          style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary)),
      if (trend.isNotEmpty) ...[
        const SizedBox(width: 8),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isUp
                ? AppColors.success.withOpacity(0.1)
                : AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(trend,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isUp ? AppColors.success : AppColors.error)),
        ),
      ],
    ]);
  }
}