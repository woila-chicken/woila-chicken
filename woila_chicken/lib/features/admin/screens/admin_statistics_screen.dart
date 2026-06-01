import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/widgets/kpi_card.dart';

class AdminStatisticsScreen extends StatelessWidget {
  const AdminStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Statistiques marché'),
        backgroundColor: AppColors.adminColor,
      ),
      body: ResponsiveLayout(
        desktop: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: _buildContent(context, isDesktop: true),
          ),
        ),
        mobile: _buildContent(context, isDesktop: false),
      ),
    );
  }

  Widget _buildContent(BuildContext context, {required bool isDesktop}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── KPIs ────────────────────────────────────────────────
        GridView.count(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  crossAxisCount: isDesktop ? 4 : 2,
  crossAxisSpacing: 12,
  mainAxisSpacing: 12,
  childAspectRatio: isDesktop ? 1.2 : 1.0,
  children: const [
    WoilaKpiCard(
      value: '128 500',
      unit: 'FCFA',
      label: 'Commissions totales',
      icon: Icons.account_balance_wallet_rounded,
      color: AppColors.success,
      trend: KpiTrend.up,
      trendLabel: '+18%',
    ),
    WoilaKpiCard(
      value: '6 425 000',
      unit: 'FCFA',
      label: 'Volume transactions',
      icon: Icons.swap_horiz_rounded,
      color: AppColors.primary,
      trend: KpiTrend.up,
      trendLabel: '+23%',
    ),
    WoilaKpiCard(
      value: '3 680',
      unit: 'FCFA',
      label: 'Prix moyen poulet',
      icon: Icons.monitor_weight_rounded,
      color: AppColors.warning,
      trend: KpiTrend.up,
      trendLabel: '+5%',
    ),
    WoilaKpiCard(
      value: '94',
      unit: '%',
      label: 'Taux de livraison',
      icon: Icons.local_shipping_rounded,
      color: AppColors.success,
      trend: KpiTrend.up,
      trendLabel: '+2%',
    ),
  ],
),
        const SizedBox(height: 24),

        // ── Graphique ventes ─────────────────────────────────────
        const _StatCard(
          title: 'Ventes mensuelles (FCFA)',
          icon: Icons.bar_chart_outlined,
          child: _BarChart(
            data: [
              _BarData(label: 'Jan', value: 0.5),
              _BarData(label: 'Fév', value: 0.65),
              _BarData(label: 'Mar', value: 0.55),
              _BarData(label: 'Avr', value: 0.8),
              _BarData(label: 'Mai', value: 1.0),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Top fermes + indicateurs ─────────────────────────────
        isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _TopFarmes()),
                  const SizedBox(width: 16),
                  Expanded(child: _MarketIndicators()),
                ],
              )
            : Column(children: [
                _TopFarmes(),
                const SizedBox(height: 16),
                _MarketIndicators(),
              ]),
      ]),
    );
  }
}


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
        const SizedBox(height: 16),
        child,
      ]),
    );
  }
}

// ─── Graphique barres simple ───────────────────────────────────────
class _BarData {
  final String label;
  final double value; // 0.0 à 1.0
  const _BarData({required this.label, required this.value});
}

class _BarChart extends StatelessWidget {
  final List<_BarData> data;
  const _BarChart({required this.data});

  @override
  Widget build(BuildContext context) {
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
                Text(
                  d.value == 1.0 ? '6.4M' : '${(d.value * 6.4).toStringAsFixed(1)}M',
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 9,
                      color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  height: d.value * 110,
                  decoration: BoxDecoration(
                    color: d.value == 1.0
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.3 + d.value * 0.4),
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
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Top fermes ────────────────────────────────────────────────────
class _TopFarmes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const _StatCard(
      title: 'Top fermes ce mois',
      icon: Icons.leaderboard_outlined,
      child: Column(
        children: [
          _FarmRankRow(rank: 1, name: 'Ferme Bougué',
              sales: 21, revenue: '88 200'),
          SizedBox(height: 8),
          _FarmRankRow(rank: 2, name: 'Ferme Koné',
              sales: 14, revenue: '49 000'),
          SizedBox(height: 8),
          _FarmRankRow(rank: 3, name: 'Ferme Alhadji',
              sales: 9, revenue: '31 500'),
        ],
      ),
    );
  }
}

class _FarmRankRow extends StatelessWidget {
  final int rank;
  final String name;
  final int sales;
  final String revenue;

  const _FarmRankRow({
    required this.rank,
    required this.name,
    required this.sales,
    required this.revenue,
  });

  Color get _rankColor {
    switch (rank) {
      case 1: return AppColors.accent;
      case 2: return AppColors.textSecondary;
      case 3: return const Color(0xFFCD7F32);
      default: return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: _rankColor.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text('#$rank',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _rankColor)),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          Text('$sales ventes',
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: AppColors.textSecondary)),
        ]),
      ),
      Text('$revenue FCFA',
          style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary)),
    ]);
  }
}

// ─── Indicateurs marché ────────────────────────────────────────────
class _MarketIndicators extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const _StatCard(
      title: 'Indicateurs marché',
      icon: Icons.insights_outlined,
      child: Column(children: [
        _IndicatorRow(label: 'Prix moyen poulet', value: '3 680 FCFA',
            trend: '+5%', isUp: true),
        SizedBox(height: 10),
        _IndicatorRow(label: 'Note satisfaction', value: '4.7 / 5 ★',
            trend: '+0.2', isUp: true),
        SizedBox(height: 10),
        _IndicatorRow(label: 'Taux livraison réussie', value: '94 %',
            trend: '+2%', isUp: true),
        SizedBox(height: 10),
        _IndicatorRow(label: 'Taux de litiges', value: '0.5 %',
            trend: '-0.1%', isUp: false),
        SizedBox(height: 10),
        _IndicatorRow(label: 'Nouvelles inscriptions', value: '2 fermes',
            trend: 'ce mois', isUp: true),
      ]),
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
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
    ]);
  }
}