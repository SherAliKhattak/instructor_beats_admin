/// Lightweight checks for admin forms (not a full RFC 5322 parser).
bool isPlausibleEmail(String trimmed) {
  return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$').hasMatch(trimmed);
}
