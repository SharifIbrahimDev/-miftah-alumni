import 'package:flutter/material.dart';
import 'dart:ui';
import '../constants/app_colors.dart';

class ToastService {
  static void showSuccess(BuildContext context, String message) {
    _showToast(context, message, Icons.check_circle_rounded, AppColors.success);
  }

  static void showError(BuildContext context, String message) {
    _showToast(context, message, Icons.error_rounded, AppColors.error);
  }

  static void _showToast(BuildContext context, String message, IconData icon, Color color) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        icon: icon,
        color: color,
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color color;
  final VoidCallback onDismiss;

  const _ToastWidget({
    super.key,
    required this.message,
    required this.icon,
    required this.color,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _slideAnimation = Tween<double>(begin: -100, end: 50).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: _slideAnimation.value,
          left: 24,
          right: 24,
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: widget.color.withOpacity(0.5), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Icon(widget.icon, color: widget.color),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
