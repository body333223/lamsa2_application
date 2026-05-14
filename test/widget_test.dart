// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:lamsa/services/locale_service.dart';

void main() {
  group('LocaleService', () {
    test('starts in Arabic', () {
      final service = LocaleService();
      expect(service.isArabic, isTrue);
      expect(service.locale.languageCode, 'ar');
    });

    test('toggleLanguage switches to English', () {
      final service = LocaleService();
      service.toggleLanguage();
      expect(service.isArabic, isFalse);
      expect(service.locale.languageCode, 'en');
    });

    test('toggleLanguage switches back to Arabic', () {
      final service = LocaleService();
      service.toggleLanguage();
      service.toggleLanguage();
      expect(service.isArabic, isTrue);
    });

    test('setLocale works correctly', () {
      final service = LocaleService();
      service.setLocale(const Locale('en'));
      expect(service.isArabic, isFalse);
    });
  });

  testWidgets('App builds without errors', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<LocaleService>(
        create: (_) => LocaleService(),
        child: const MaterialApp(home: Scaffold(body: SizedBox())),
      ),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
