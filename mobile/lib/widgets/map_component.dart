import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants.dart';
import 'package:customer_app/l10n/app_localizations.dart';
import '../utils/l10n_extension.dart';

class MapComponent extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String title;
  final String address;
  final double height;

  const MapComponent({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.title,
    required this.address,
    this.height = 250,
  });

  Future<void> _openExternalMaps() async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    // If API Key is missing, show professional fallback
    if (AppConstants.googleMapsApiKey.isEmpty) {
      return Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.mapConfigUnavailableAlt,
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.locationLatLng(
                latitude.toString(),
                longitude.toString(),
              ),
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _openExternalMaps,
              icon: const Icon(Icons.open_in_new, size: 18),
              label: Text(loc.openExternalMaps),
            ),
          ],
        ),
      );
    }

    // Actual Google Maps Implementation
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(latitude, longitude),
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('location_marker'),
                  position: LatLng(latitude, longitude),
                  infoWindow: InfoWindow(title: title, snippet: address),
                ),
              },
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.small(
                onPressed: _openExternalMaps,
                backgroundColor: colorScheme.surface,
                child: Icon(Icons.directions, color: colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
