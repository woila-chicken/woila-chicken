import 'package:flutter/material.dart';

class PageWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;

  const PageWrapper({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.padding = const EdgeInsets.all(32),
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // Sur mobile, pas de contrainte
    if (width < 768) return child;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}