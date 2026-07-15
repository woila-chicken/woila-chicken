import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class QuantityStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const QuantityStepper({super.key, 
    required this.value,
    required this.onChanged,
  });

  int get _tens => value ~/ 10;
  int get _units => value % 10;

  @override
  Widget build(BuildContext context) {
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
          onTap: value > 0 ? () => onChanged(value - 1) : null,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          ),
          child: SizedBox(
            width: 40,
            height: 56,
            child: Icon(
              Icons.remove_rounded,
              size: 18,
              color: value > 0
                  ? AppColors.primary
                  : AppColors.textSecondary.withOpacity(0.3),
            ),
          ),
        ),

        Container(width: 0.5, height: 36, color: AppColors.divider),

        // Molette dizaines
        Expanded(
          child: _Wheel(
            value: _tens,
            min: 0,
            max: 9,
            onChanged: (t) => onChanged(t * 10 + _units),
          ),
        ),

        // Séparateur
        const Text('',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),

        // Molette unités
        Expanded(
          child: _Wheel(
            value: _units,
            min: 0,
            max: 9,
            onChanged: (u) => onChanged(_tens * 10 + u),
          ),
        ),

        Container(width: 0.5, height: 36, color: AppColors.divider),

        // Bouton plus
        InkWell(
          onTap: value < 99 ? () => onChanged(value + 1) : null,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          child: SizedBox(
            width: 40,
            height: 56,
            child: Icon(
              Icons.add_rounded,
              size: 18,
              color: value < 99
                  ? AppColors.primary
                  : AppColors.textSecondary.withOpacity(0.3),
            ),
          ),
        ),
      ]),
    );
  }
}


class _Wheel extends StatefulWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _Wheel({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  State<_Wheel> createState() => _WheelState();
}

class _WheelState extends State<_Wheel> {
  late final FixedExtentScrollController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = FixedExtentScrollController(
        initialItem: widget.value - widget.min);
  }

  @override
  void didUpdateWidget(_Wheel old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _ctrl.jumpToItem(widget.value - widget.min);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.max - widget.min + 1;
    return SizedBox(
      height: 56,
      child: ListWheelScrollView.useDelegate(
        controller: _ctrl,
        itemExtent: 36,
        physics: const FixedExtentScrollPhysics(),
        perspective: 0.003,
        onSelectedItemChanged: (i) =>
            widget.onChanged(widget.min + i),
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: count,
          builder: (context, i) {
            final num = widget.min + i;
            final isSelected = num == widget.value;
            return Center(
              child: Text(
                '$num',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: isSelected ? 20 : 15,
                  fontWeight: isSelected
                      ? FontWeight.w800
                      : FontWeight.normal,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

