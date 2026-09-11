import 'dart:typed_data';

import 'package:image/image.dart' as img;

class CompressedImage {
  final Uint8List bytes;
  final String mimeType;

  const CompressedImage({required this.bytes, required this.mimeType});
}

/// Resizes and re-encodes a photo as JPEG, targeting a maximum byte size
/// (default ~500KB) before it is uploaded. Runs entirely in pure Dart (the
/// `image` package) so it needs no native platform configuration.
///
/// Strategy: cap the longest edge at [maxDimension], then step the JPEG
/// quality down until the encoded size fits under [maxBytes] or the
/// quality floor is hit — whichever comes first.
CompressedImage compressForUpload(
  Uint8List originalBytes, {
  int maxBytes = 500 * 1024,
  int maxDimension = 1280,
}) {
  img.Image? decoded;
  try {
    decoded = img.decodeImage(originalBytes);
  } catch (_) {
    decoded = null;
  }
  if (decoded == null) {
    // Not a decodable raster image (e.g. malformed input or an unusual
    // format); upload as-is rather than fail the whole flow.
    return CompressedImage(bytes: originalBytes, mimeType: 'image/jpeg');
  }

  img.Image resized = decoded;
  final longestEdge = decoded.width > decoded.height
      ? decoded.width
      : decoded.height;
  if (longestEdge > maxDimension) {
    resized = decoded.width >= decoded.height
        ? img.copyResize(decoded, width: maxDimension)
        : img.copyResize(decoded, height: maxDimension);
  }

  const qualitySteps = [85, 75, 65, 55, 45, 35, 25];
  Uint8List encoded = Uint8List.fromList(
    img.encodeJpg(resized, quality: qualitySteps.first),
  );

  for (final quality in qualitySteps.skip(1)) {
    if (encoded.lengthInBytes <= maxBytes) break;
    encoded = Uint8List.fromList(img.encodeJpg(resized, quality: quality));
  }

  return CompressedImage(bytes: encoded, mimeType: 'image/jpeg');
}
