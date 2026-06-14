import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum KpiTrend { up, down, neutral }

class WoilaKpiCard extends StatelessWidget {
  final String value;
  final String label;
  final String? unit;
  final IconData icon;
  final Color color;
  final KpiTrend trend;
  final String? trendLabel;
  final VoidCallback? onTap;

  const WoilaKpiCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    this.unit,
    this.trend = KpiTrend.neutral,
    this.trendLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.15), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icône + badge trend sur la même ligne ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.15),
                        color.withOpacity(0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                if (trendLabel != null)
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: _trendColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_trendIcon, size: 10, color: _trendColor),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              trendLabel!,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: _trendColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Valeur ──────────────────────────────────
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (unit != null)
                      TextSpan(
                        text: '  $unit',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),

            // ── Label ────────────────────────────────────
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),

            // ── Barre décorative ─────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _progressValue,
                backgroundColor: color.withOpacity(0.08),
                valueColor:
                    AlwaysStoppedAnimation<Color>(color.withOpacity(0.5)),
                minHeight: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color get _trendColor {
    switch (trend) {
      case KpiTrend.up:
        return AppColors.success;
      case KpiTrend.down:
        return AppColors.error;
      case KpiTrend.neutral:
        return AppColors.textSecondary;
    }
  }

  IconData get _trendIcon {
    switch (trend) {
      case KpiTrend.up:
        return Icons.trending_up_rounded;
      case KpiTrend.down:
        return Icons.trending_down_rounded;
      case KpiTrend.neutral:
        return Icons.trending_flat_rounded;
    }
  }

  double get _progressValue {
    final num =
        double.tryParse(value.replaceAll(' ', '').replaceAll('%', '')) ?? 0;
    if (num <= 0) return 0.3;
    if (num >= 100) return 1.0;
    if (num >= 1000) return (num / 10000).clamp(0.1, 0.95);
    return (num / 100).clamp(0.1, 0.95);
  }
}
