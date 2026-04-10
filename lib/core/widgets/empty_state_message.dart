import 'package:flutter/material.dart';

/// Centered friendly empty state for admin list areas (and dashboard cards).
class EmptyStateMessage extends StatelessWidget {
  const EmptyStateMessage({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.titleColor,
    this.messageColor,
    this.iconColor,
  });

  final String title;
  final String message;
  final IconData? icon;
  final Color? titleColor;
  final Color? messageColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final titleC = titleColor ?? scheme.onSurface;
    final messageC = messageColor ?? scheme.onSurfaceVariant;
    final iconC = iconColor ?? messageC.withValues(alpha: 0.45);

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 52, color: iconC),
                const SizedBox(height: 20),
              ],
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: titleC,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: messageC,
                  height: 1.45,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
