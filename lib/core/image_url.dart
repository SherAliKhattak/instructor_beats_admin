/// Trims and strips invisible characters that often break [Image.network] / Storage.
String normalizeImageUrl(String raw) {
  return raw
      .trim()
      .replaceAll(String.fromCharCode(0x200B), '')
      .replaceAll(String.fromCharCode(0xFEFF), '');
}
