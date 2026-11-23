import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../../shared/theme/greenloop_theme.dart';

const depokMapCenter = LatLng(-6.3627, 106.82715);

Map<String, String> get _geocodingHeaders => kIsWeb
    ? const <String, String>{}
    : const <String, String>{'User-Agent': 'GreenLoopMobile/1.0'};

class MitraLocationSelection {
  const MitraLocationSelection({
    required this.point,
    this.address,
    this.province,
    this.city,
    this.district,
    this.village,
  });

  final LatLng point;
  final String? address;
  final String? province;
  final String? city;
  final String? district;
  final String? village;
}

/// Mobile counterpart of the web Leaflet picker. The map stays read-only until
/// the Mitra explicitly unlocks it; moving/searching a point resolves its area.
class MitraLocationPicker extends StatefulWidget {
  const MitraLocationPicker({
    required this.initialPoint,
    required this.editable,
    required this.onPointChanged,
    required this.onLocationValidityChanged,
    required this.onLocationNeedsResolution,
    super.key,
  });

  final LatLng initialPoint;
  final bool editable;
  final ValueChanged<MitraLocationSelection> onPointChanged;
  final ValueChanged<bool> onLocationValidityChanged;
  final VoidCallback onLocationNeedsResolution;

  @override
  State<MitraLocationPicker> createState() => _MitraLocationPickerState();
}

class _MitraLocationPickerState extends State<MitraLocationPicker> {
  final _mapController = MapController();
  final _searchController = TextEditingController();
  Timer? _reverseTimer;
  DateTime? _lastGeocodingRequest;
  late LatLng _center = widget.initialPoint;
  List<LatLng> _depokBoundary = const [];
  bool _loadingAddress = false;
  bool _needsResolutionReported = false;
  String? _mapError;

  @override
  void initState() {
    super.initState();
    _loadBoundary();
  }

  Future<void> _loadBoundary() async {
    try {
      final raw = await rootBundle.loadString('assets/depok_boundary.json');
      final coordinates = jsonDecode(raw) as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _depokBoundary = coordinates
            .cast<List<dynamic>>()
            .map((coordinate) => LatLng(
                  (coordinate[1] as num).toDouble(),
                  (coordinate[0] as num).toDouble(),
                ))
            .toList(growable: false);
      });
    } catch (_) {
      if (mounted) setState(() => _mapError = 'Batas wilayah Depok belum bisa dimuat.');
    }
  }

  bool _insideDepok(LatLng point) {
    if (_depokBoundary.length < 3) return false;
    var inside = false;
    for (var i = 0, j = _depokBoundary.length - 1; i < _depokBoundary.length; j = i++) {
      final a = _depokBoundary[i];
      final b = _depokBoundary[j];
      if ((a.latitude > point.latitude) != (b.latitude > point.latitude) &&
          point.longitude < (b.longitude - a.longitude) *
                  (point.latitude - a.latitude) /
                  (b.latitude - a.latitude) +
              a.longitude) {
        inside = !inside;
      }
    }
    return inside;
  }

  @override
  void didUpdateWidget(covariant MitraLocationPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPoint != widget.initialPoint) {
      _center = widget.initialPoint;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _mapController.move(_center, 16);
      });
    }
  }

  @override
  void dispose() {
    _reverseTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onMapMoved(MapCamera camera, bool hasGesture) {
    if (!widget.editable || !hasGesture) return;
    _center = camera.center;
    _reverseTimer?.cancel();
    widget.onLocationValidityChanged(_insideDepok(_center));
    if (!_needsResolutionReported) {
      _needsResolutionReported = true;
      widget.onLocationNeedsResolution();
    }
    if (!_insideDepok(_center)) {
      if (_mapError != 'Titik lokasi harus berada di dalam Kota Depok.' && mounted) {
        setState(() => _mapError = 'Titik lokasi harus berada di dalam Kota Depok.');
      }
      return;
    }
    if (_mapError == 'Titik lokasi harus berada di dalam Kota Depok.') {
      setState(() => _mapError = null);
    }
    _reverseTimer = Timer(const Duration(milliseconds: 1200), _reverseGeocode);
  }

  Future<void> _respectGeocodingLimit() async {
    final lastRequest = _lastGeocodingRequest;
    if (lastRequest != null) {
      final wait = const Duration(seconds: 1) - DateTime.now().difference(lastRequest);
      if (wait > Duration.zero) await Future<void>.delayed(wait);
    }
    _lastGeocodingRequest = DateTime.now();
  }

  Future<void> _searchAddress() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _loadingAddress = true;
      _mapError = null;
    });
    try {
      await _respectGeocodingLimit();
      if (!mounted) return;
      final response = await http.get(
        Uri.https('nominatim.openstreetmap.org', '/search', {
          'format': 'jsonv2',
          'addressdetails': '1',
          'countrycodes': 'id',
          'q': query,
        }),
        headers: _geocodingHeaders,
      );
      if (response.statusCode != 200) throw const FormatException();
      final rows = jsonDecode(response.body) as List<dynamic>;
      if (rows.isEmpty) {
        setState(() => _mapError = 'Alamat tidak ditemukan. Coba kata kunci lain.');
        return;
      }
      final result = rows.first as Map<String, dynamic>;
      final point = LatLng(
        double.parse(result['lat'] as String),
        double.parse(result['lon'] as String),
      );
      if (!_insideDepok(point)) {
        setState(() => _mapError = 'Pilih titik lokasi di dalam Kota Depok.');
        return;
      }
      widget.onLocationValidityChanged(true);
      _needsResolutionReported = true;
      widget.onLocationNeedsResolution();
      _mapController.move(point, 16);
      _center = point;
      await _reverseGeocode();
    } catch (_) {
      if (mounted) setState(() => _mapError = 'Pencarian lokasi gagal. Periksa koneksi internet.');
    } finally {
      if (mounted) setState(() => _loadingAddress = false);
    }
  }

  Future<void> _reverseGeocode() async {
    if (!mounted || !widget.editable || !_insideDepok(_center)) return;
    final requestedPoint = _center;
    setState(() => _loadingAddress = true);
    try {
      await _respectGeocodingLimit();
      if (!mounted || !widget.editable || _center != requestedPoint) return;
      final response = await http.get(
        Uri.https('nominatim.openstreetmap.org', '/reverse', {
          'format': 'jsonv2',
          'addressdetails': '1',
          'zoom': '18',
          'accept-language': 'id',
          'lat': _center.latitude.toString(),
          'lon': _center.longitude.toString(),
        }),
        headers: _geocodingHeaders,
      );
      if (response.statusCode != 200) throw const FormatException();
      if (!mounted || _center != requestedPoint) return;
      final result = jsonDecode(response.body) as Map<String, dynamic>;
      final area = result['address'] as Map<String, dynamic>? ?? const {};
      String? first(List<String> keys) {
        for (final key in keys) {
          final value = area[key];
          if (value is String && value.trim().isNotEmpty) return value;
        }
        return null;
      }

      widget.onPointChanged(MitraLocationSelection(
        point: requestedPoint,
        address: result['display_name'] as String?,
        province: first(const ['state']),
        city: first(const ['city', 'county', 'town', 'municipality']),
        district: first(const ['city_district', 'suburb', 'district', 'subdistrict']),
        village: first(const ['village', 'neighbourhood', 'quarter', 'hamlet']),
      ));
      _needsResolutionReported = false;
      if (mounted) setState(() => _mapError = null);
    } catch (_) {
      if (mounted) setState(() => _mapError = 'Alamat titik belum bisa dimuat. Titik tetap tersimpan.');
      if (mounted && _center == requestedPoint) {
        widget.onPointChanged(MitraLocationSelection(point: requestedPoint));
      }
    } finally {
      if (mounted) setState(() => _loadingAddress = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (widget.editable) ...[
        Row(children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _searchAddress(),
              decoration: const InputDecoration(
                hintText: 'Cari alamat atau nama tempat',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            tooltip: 'Cari lokasi',
            onPressed: _loadingAddress ? null : _searchAddress,
            icon: _loadingAddress
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.search),
          ),
        ]),
        const SizedBox(height: 9),
      ],
      ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: SizedBox(
          height: 220,
          child: Stack(alignment: Alignment.center, children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _center,
                initialZoom: widget.initialPoint == depokMapCenter ? 11 : 16,
                interactionOptions: InteractionOptions(
                  flags: widget.editable
                      ? InteractiveFlag.all
                      : InteractiveFlag.none,
                ),
                onPositionChanged: _onMapMoved,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.greenloop.mobile',
                ),
                if (_depokBoundary.length > 2)
                  PolygonLayer(polygons: [
                    Polygon(
                      points: _depokBoundary,
                      borderColor: GreenLoopColors.circleGreen,
                      borderStrokeWidth: 2,
                      color: GreenLoopColors.circleGreen.withValues(alpha: .07),
                    ),
                  ]),
                const RichAttributionWidget(
                  attributions: [TextSourceAttribution('© OpenStreetMap contributors')],
                ),
              ],
            ),
            IgnorePointer(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Icon(Icons.location_pin, size: 42, color: GreenLoopColors.circleGreen),
              ),
            ),
            if (_loadingAddress)
              const Positioned(right: 10, top: 10, child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
          ]),
        ),
      ),
      const SizedBox(height: 8),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(widget.editable ? Icons.lock_open : Icons.lock_outline, size: 17, color: GreenLoopColors.circleGreen),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            widget.editable
                ? 'Geser peta hingga pin tepat di lokasi usaha. Titik akan dikunci setelah disimpan.'
                : 'Titik lokasi tersimpan dan terkunci. Tekan tombol ubah untuk menyesuaikannya.',
            style: const TextStyle(fontSize: 11, height: 1.35, color: GreenLoopColors.muted),
          ),
        ),
      ]),
      if (_mapError != null) ...[
        const SizedBox(height: 6),
        Text(_mapError!, style: const TextStyle(color: Colors.red, fontSize: 11)),
      ],
    ],
  );
}
