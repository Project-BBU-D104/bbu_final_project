class BarcodeUtils {
  BarcodeUtils._();

  static final RegExp _numeric = RegExp(r'^[0-9]+$');

  /// Normalizes a barcode for comparison.
  ///
  /// Numeric barcodes are compared without leading zeroes because the same
  /// product can be read as UPC-A (12 digits) or EAN-13 (13 digits with a
  /// leading zero).
  static String normalize(String value) {
    final normalized = value.trim().toLowerCase();

    if (_numeric.hasMatch(normalized)) {
      return normalized.replaceFirst(RegExp(r'^0+'), '');
    }

    return normalized;
  }

  static bool matches(String barcode, String query) {
    final normalizedBarcode = normalize(barcode);
    final normalizedQuery = normalize(query);

    if (normalizedBarcode.isEmpty || normalizedQuery.isEmpty) {
      return false;
    }

    return normalizedBarcode.contains(normalizedQuery);
  }

  static bool equals(String barcode, String other) {
    final normalizedBarcode = normalize(barcode);
    final normalizedOther = normalize(other);

    return normalizedBarcode.isNotEmpty &&
        normalizedBarcode == normalizedOther;
  }
}
