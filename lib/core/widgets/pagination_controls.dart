import 'package:flutter/material.dart';
import 'package:instructor_beats_admin/core/pagination_utils.dart';

/// First / Prev / numbered pages (sliding window) / Next / Last — matches your snippet UX.
class PaginationControls extends StatelessWidget {
  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalItems,
    required this.itemsPerPage,
    required this.onPageChanged,
    this.activeColor,
    this.inactiveColor,
  });

  final int currentPage;
  final int totalItems;
  final int itemsPerPage;
  final ValueChanged<int> onPageChanged;
  final Color? activeColor;
  final Color? inactiveColor;

  int get totalPages =>
      totalItems <= 0 ? 1 : (totalItems / itemsPerPage).ceil();

  List<int> get _visible => PaginationUtils.visiblePages(
        currentPage: currentPage,
        totalPages: totalPages,
        maxVisible: 3,
      );

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    final inactive =
        inactiveColor ?? scheme.surfaceContainerHighest;
    final active = activeColor ?? scheme.primary;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 4,
      children: [
        _IconPageButton(
          onPressed: currentPage > 1 ? () => onPageChanged(1) : null,
          inactiveColor: inactive,
          child: const Icon(Icons.keyboard_double_arrow_left, size: 18),
        ),
        _IconPageButton(
          onPressed: currentPage > 1
              ? () => onPageChanged(currentPage - 1)
              : null,
          inactiveColor: inactive,
          child: const Icon(Icons.keyboard_arrow_left, size: 18),
        ),
        ..._visible.map(
          (page) => _NumberPageButton(
            page: page,
            isActive: page == currentPage,
            activeColor: active,
            inactiveColor: inactive,
            onTap: () => onPageChanged(page),
          ),
        ),
        _IconPageButton(
          onPressed: currentPage < totalPages
              ? () => onPageChanged(currentPage + 1)
              : null,
          inactiveColor: inactive,
          child: const Icon(Icons.keyboard_arrow_right, size: 18),
        ),
        _IconPageButton(
          onPressed: currentPage < totalPages
              ? () => onPageChanged(totalPages)
              : null,
          inactiveColor: inactive,
          child: const Icon(Icons.keyboard_double_arrow_right, size: 18),
        ),
      ],
    );
  }
}

class _IconPageButton extends StatelessWidget {
  const _IconPageButton({
    required this.onPressed,
    required this.child,
    this.inactiveColor,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = scheme.onSurfaceVariant;
    return SizedBox(
      width: 30,
      height: 30,
      child: Material(
        color: inactiveColor,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Center(
            child: IconTheme(
              data: IconThemeData(
                color: onPressed != null
                    ? fg
                    : fg.withValues(alpha: 0.35),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _NumberPageButton extends StatelessWidget {
  const _NumberPageButton({
    required this.page,
    required this.isActive,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
  });

  final int page;
  final bool isActive;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 33,
      height: 33,
      child: Material(
        color: isActive
            ? activeColor
            : inactiveColor,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Center(
            child: Text(
              '$page',
              style: TextStyle(
                color: isActive
                    ? scheme.onPrimary
                    : scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
