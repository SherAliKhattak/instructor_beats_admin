import 'dart:math' as math;

/// Page window logic matching the admin pagination snippet (max 3 numbers).
class PaginationUtils {
  PaginationUtils._();

  static List<int> visiblePages({
    required int currentPage,
    required int totalPages,
    int maxVisible = 3,
  }) {
    if (totalPages <= 0) return [];
    final cap = math.min(maxVisible, totalPages);
    if (totalPages <= cap) {
      return List<int>.generate(totalPages, (i) => i + 1);
    }
    var start = math.max(1, currentPage - 2);
    var end = math.min(totalPages, start + cap - 1);
    if (end - start < cap - 1) {
      start = math.max(1, end - cap + 1);
    }
    return [for (var i = start; i <= end; i++) i];
  }
}
