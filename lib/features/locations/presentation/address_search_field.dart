import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/nominatim_address_service.dart';

/// Type-ahead address search backed by OpenStreetMap (Nominatim). Picking a
/// suggestion hands the caller a fully-geocoded [NominatimAddressResult]
/// (with lat/lon already filled in) to auto-fill the rest of the form.
class AddressSearchField extends StatefulWidget {
  final ValueChanged<NominatimAddressResult> onSelected;

  const AddressSearchField({super.key, required this.onSelected});

  @override
  State<AddressSearchField> createState() => _AddressSearchFieldState();
}

class _AddressSearchFieldState extends State<AddressSearchField> {
  final _service = NominatimAddressService();
  final _controller = TextEditingController();
  Timer? _debounce;
  List<NominatimAddressResult> _results = [];
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (value.trim().length < 3) {
      setState(() {
        _results = [];
        _loading = false;
        _error = null;
      });
      return;
    }
    // Nominatim's usage policy caps public-server use at ~1 request/second —
    // debounce keystrokes well past that before actually searching.
    _debounce = Timer(const Duration(milliseconds: 700), () => _search(value));
  }

  Future<void> _search(String query) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await _service.search(query);
      if (mounted) setState(() => _results = results);
    } catch (_) {
      if (mounted) setState(() => _error = 'Gagal mencari alamat. Periksa koneksi Anda.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _select(NominatimAddressResult result) {
    widget.onSelected(result);
    setState(() {
      _results = [];
      _controller.clear();
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          onChanged: _onChanged,
          decoration: InputDecoration(
            labelText: 'Cari alamat (OpenStreetMap)',
            hintText: 'contoh: Jl. Merdeka, Bandung',
            prefixIcon: const Icon(Icons.search, color: AppColors.navy),
            suffixIcon: _loading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(_error!, style: const TextStyle(color: AppColors.maroon, fontSize: 12)),
          ),
        if (_results.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                for (var i = 0; i < _results.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.place_outlined, color: AppColors.gold),
                    title: Text(
                      _results[i].displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                    onTap: () => _select(_results[i]),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
