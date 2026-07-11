import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';

enum ToastType { success, error, warning, info }

class WoilaToast {
  static void success(String title, String message) =>
      _show(title, message, ToastType.success);

  static void error(String title, String message) =>
      _show(title, message, ToastType.error);

  static void warning(String title, String message) =>
      _show(title, message, ToastType.warning);

  static void info(String title, String message) =>
      _show(title, message, ToastType.info);

  static void _show(String title, String message, ToastType type) {
    // Utilise Get.overlayContext au lieu du navigatorKey
    final context = Get.overlayContext;
    if (context == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _WoilaToastWidget(
        title: title,
        message: message,
        type: type,
        onDismiss: () => entry.remove(),
      ),
    );

    Overlay.of(context).insert(entry);
  }
}

class _WoilaToastWidget extends StatefulWidget {
  final String title;
  final String message;
  final ToastType type;
  final VoidCallback onDismiss;

  const _WoilaToastWidget({
    required this.title,
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<_WoilaToastWidget> createState() => _WoilaToastWidgetState();
}

class _WoilaToastWidgetState extends State<_WoilaToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;
  bool _hovering = false;
  static const _duration = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _ctrl.forward();
    _scheduleDismiss();
  }

  void _scheduleDismiss() {
    Future.delayed(_duration, () {
      if (mounted && !_hovering) _dismiss();
    });
  }

  void _dismiss() {
    if (!mounted) return;
    _ctrl.reverse().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  IconData get _icon {
    switch (widget.type) {
      case ToastType.success: return Icons.check_circle_rounded;
      case ToastType.error:   return Icons.error_rounded;
      case ToastType.warning: return Icons.warning_rounded;
      case ToastType.info:    return Icons.notifications_rounded;
    }
  }

  Color get _color {
    switch (widget.type) {
      case ToastType.success: return AppColors.success;
      case ToastType.error:   return AppColors.error;
      case ToastType.warning: return AppColors.warning;
      case ToastType.info:    return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 14,
      right: 14,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _opacity,
          child: MouseRegion(
            onEnter: (_) => setState(() => _hovering = true),
            onExit: (_) {
              setState(() => _hovering = false);
              _scheduleDismiss();
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: Colors.black.withValues(alpha: 0.06),
                      width: 0.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(14, 13, 14, 13),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: _color.withValues(alpha: 0.1),
                                borderRadius:
                                    BorderRadius.circular(9),
                              ),
                              child: Icon(_icon,
                                  color: _color, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title,
                                    style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.message,
                                    style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        height: 1.4),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: _dismiss,
                              child: Icon(
                                Icons.close_rounded,
                                size: 15,
                                color: AppColors.textSecondary
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Barre de progression
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 1.0, end: 0.0),
                        duration: _duration,
                        builder: (_, value, __) => _hovering
                            ? const SizedBox(height: 3)
                            : LinearProgressIndicator(
                                value: value,
                                minHeight: 3,
                                backgroundColor: Colors.transparent,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                  _color.withValues(alpha: 0.35),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}