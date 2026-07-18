import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class QuantityStepper extends StatefulWidget {
  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    required this.max,
  });

  @override
  State<QuantityStepper> createState() => _QuantityStepperState();
}

class _QuantityStepperState extends State<QuantityStepper> {
  late FixedExtentScrollController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = FixedExtentScrollController(
      initialItem: (widget.value - 1).clamp(0, widget.max - 1),
    );
  }

  @override
  void didUpdateWidget(QuantityStepper old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value || old.max != widget.max) {
      final target = (widget.value - 1).clamp(0, widget.max - 1);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _ctrl.jumpToItem(target);
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.max <= 0) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: const Center(
          child: Text('Rupture de stock',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error)),
        ),
      );
    }

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(children: [
        // Bouton moins
        InkWell(
          onTap: widget.value > 1
              ? () => widget.onChanged(widget.value - 1)
              : null,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          ),
          child: SizedBox(
            width: 40,
            height: 56,
            child: Icon(Icons.remove_rounded,
                size: 18,
                color: widget.value > 1
                    ? AppColors.primary
                    : AppColors.textSecondary.withValues(alpha: 0.3)),
          ),
        ),

        Container(width: 0.5, height: 36, color: AppColors.divider),

        // Molette
        Expanded(
          child: SizedBox(
            height: 56,
            child: ListWheelScrollView.useDelegate(
              controller: _ctrl,
              itemExtent: 36,
              physics: const FixedExtentScrollPhysics(),
              perspective: 0.003,
              onSelectedItemChanged: (i) => widget.onChanged(i + 1),
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: widget.max,
                builder: (context, i) {
                  final num = i + 1;
                  final isSelected = num == widget.value;
                  return Center(
                    child: Text(
                      '$num',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: isSelected ? 20 : 14,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.normal,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        Container(width: 0.5, height: 36, color: AppColors.divider),

        // Bouton plus
        InkWell(
          onTap: widget.value < widget.max
              ? () => widget.onChanged(widget.value + 1)
              : null,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          child: SizedBox(
            width: 40,
            height: 56,
            child: Icon(Icons.add_rounded,
                size: 18,
                color: widget.value < widget.max
                    ? AppColors.primary
                    : AppColors.textSecondary.withValues(alpha: 0.3)),
          ),
        ),
      ]),
    );
  }
}
