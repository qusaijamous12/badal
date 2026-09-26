import 'dart:typed_data';

import 'package:badal/app/swap/image_processing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('large photo is reduced below Firestore image limit', () {
    final source = img.Image(width: 1200, height: 900);
    for (var y = 0; y < source.height; y++) {
      for (var x = 0; x < source.width; x++) {
        source.setPixelRgb(x, y, x % 256, y % 256, (x + y) % 256);
      }
    }
    final jpg = Uint8List.fromList(img.encodeJpg(source, quality: 95));
    final compressed = compressItemImage(jpg);
    expect(compressed.length, lessThanOrEqualTo(450000));
    expect(img.decodeJpg(compressed), isNotNull);
  });

  test('invalid image data is rejected', () {
    expect(() => compressItemImage(Uint8List.fromList([1, 2, 3])), throwsStateError);
  });
}
