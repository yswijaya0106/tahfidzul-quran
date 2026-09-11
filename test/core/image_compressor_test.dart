import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:tahfidzul_quran/core/media/image_compressor.dart';

Uint8List _syntheticPhoto({int width = 3000, int height = 2000}) {
  final image = img.Image(width: width, height: height);
  // A gradient (rather than a flat fill) keeps JPEG from compressing the
  // synthetic image trivially small, so the size-reduction assertions below
  // are meaningful.
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      image.setPixelRgb(
        x,
        y,
        (x * 255) ~/ width,
        (y * 255) ~/ height,
        (x + y) % 255,
      );
    }
  }
  return Uint8List.fromList(img.encodeJpg(image, quality: 100));
}

void main() {
  test('resizes and compresses a large photo under the target size', () {
    final original = _syntheticPhoto();
    final result = compressForUpload(
      original,
      maxBytes: 500 * 1024,
      maxDimension: 1280,
    );

    expect(result.mimeType, 'image/jpeg');
    expect(result.bytes.lengthInBytes, lessThan(original.lengthInBytes));
    expect(result.bytes.lengthInBytes, lessThanOrEqualTo(500 * 1024));

    final decoded = img.decodeImage(result.bytes)!;
    expect(decoded.width <= 1280 && decoded.height <= 1280, isTrue);
  });

  test('leaves an already-small photo close to its own size', () {
    final small = _syntheticPhoto(width: 200, height: 150);
    final result = compressForUpload(
      small,
      maxBytes: 500 * 1024,
      maxDimension: 1280,
    );

    final decoded = img.decodeImage(result.bytes)!;
    expect(decoded.width, 200);
    expect(decoded.height, 150);
  });

  test('falls back to the original bytes for undecodable input', () {
    final garbage = Uint8List.fromList([1, 2, 3, 4, 5]);
    final result = compressForUpload(garbage);

    expect(result.bytes, garbage);
  });
}
