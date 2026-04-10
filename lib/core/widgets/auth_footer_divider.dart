import 'package:flutter/material.dart';

class AuthFooterDivider extends StatelessWidget {
  const AuthFooterDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(child: Divider(color: scheme.outline.withValues(alpha: 0.85))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or',
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: scheme.outline.withValues(alpha: 0.85))),
      ],
    );
  }
}
