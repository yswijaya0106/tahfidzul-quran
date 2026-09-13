import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/location.dart';

/// Opens a location in Google Maps (the app if installed, else the browser)
/// — by exact coordinates when available, falling back to a text search on
/// its address otherwise.
Future<void> openLocationInGoogleMaps(
  BuildContext context,
  TahfidzLocation location,
) async {
  final query = location.latitude != null && location.longitude != null
      ? '${location.latitude},${location.longitude}'
      : location.addressLine;
  final uri = Uri.https('www.google.com', '/maps/search/', {
    'api': '1',
    'query': query,
  });

  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Tidak dapat membuka Google Maps.')));
  }
}
