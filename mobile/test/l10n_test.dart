import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:customer_app/config/locale_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocaleController Tests', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial locale defaults to English (en)', () {
      final state = container.read(localeControllerProvider);
      expect(state.languageCode, 'en');
    });

    test('Can switch locale to Hindi (hi)', () async {
      final logic = container.read(localeControllerProvider.notifier);
      container.listen(localeControllerProvider, (_, _) {});

      await logic.setLocale('hi');

      final state = container.read(localeControllerProvider);
      expect(state.languageCode, 'hi');
    });
  });
}
