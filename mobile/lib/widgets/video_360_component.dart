import 'package:flutter/material.dart';
import 'package:customer_app/l10n/app_localizations.dart';
import '../utils/l10n_extension.dart';

class Video360Component extends StatelessWidget {
  final String? videoUrl;
  final double height;
  final String placeholderImage;

  const Video360Component({
    super.key,
    this.videoUrl,
    this.height = 300,
    required this.placeholderImage,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    if (videoUrl == null || videoUrl!.isEmpty) {
      return Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: NetworkImage(placeholderImage),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.6),
              BlendMode.darken,
            ),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.threesixty, size: 64, color: Colors.white70),
              const SizedBox(height: 16),
              Text(
                context.l10n.view360ComingSoon,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Foundation for actual 360 player integration.
    // e.g. Using panorama or similar package later when real URLs arrive.
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Simulate Player
          Opacity(
            opacity: 0.5,
            child: Image.network(
              placeholderImage,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.play_circle_fill,
              size: 64,
              color: Colors.white,
            ),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(loc.starting360)));
            },
          ),
          Positioned(
            top: 16,
            left: 16,
            child: Chip(
              label: Text(
                context.l10n.immersive360,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}
