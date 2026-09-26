import 'dart:typed_data';

import 'package:image/image.dart' as img;

Uint8List compressItemImage(Uint8List source) {
  img.Image? decoded;
  try {
    decoded = img.decodeImage(source);
  } catch (_) {
    throw StateError('صيغة الصورة غير مدعومة. اختر صورة JPG أو PNG.');
  }
  if (decoded == null) {
    throw StateError('صيغة الصورة غير مدعومة. اختر صورة JPG أو PNG.');
  }
  for (final width in [800, 650, 500]) {
    final resized = decoded.width > width
        ? img.copyResize(decoded, width: width)
        : decoded;
    for (final quality in [65, 50, 38]) {
      final result = img.encodeJpg(resized, quality: quality);
      if (result.length <= 450000) return result;
    }
  }
  throw StateError('الصورة كبيرة جدًا. اختر صورة أخرى.');
}
