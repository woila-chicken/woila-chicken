import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final double borderRadius;
  final double iconSize;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.width = 56,
    this.height = 56,
    this.borderRadius = 10,
    this.iconSize = 26,
  });

  bool get _hasImage =>
      imageUrl != null &&
      imageUrl!.isNotEmpty &&
      imageUrl!.startsWith('http');

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: _hasImage
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                width: width,
                height: height,
                loadingBuilder: (_, child, progress) =>
                    progress == null
                        ? child
                        : Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                errorBuilder: (_, __, ___) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Center(
      child: Icon(
        Icons.egg_rounded,
        color: AppColors.primary.withValues(alpha: 0.3),
        size: iconSize,
      ),
    );
  }
}