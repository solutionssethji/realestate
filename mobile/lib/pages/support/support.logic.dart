import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'support.state.dart';

part 'support.logic.g.dart';

@riverpod
class SupportLogic extends _$SupportLogic {
  @override
  SupportState build() {
    return const SupportState();
  }

  Future<void> launchSupportUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
  }
}
