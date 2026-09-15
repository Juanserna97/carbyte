import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_language.dart';
import 'app_strings.dart';
import 'translations_es.dart';
import 'translations_en.dart';

export 'app_language.dart';
export 'app_strings.dart';

const String _prefLanguageKey = 'carbyte_selected_language';

class LanguageNotifier extends StateNotifier<AppLanguage> {
  LanguageNotifier() : super(AppLanguage.auto) {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_prefLanguageKey);
      if (savedCode != null) {
        state = AppLanguage.values.firstWhere(
          (lang) => lang.name == savedCode,
          orElse: () => AppLanguage.auto,
        );
      }
    } catch (_) {
      // Fallback to auto
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefLanguageKey, language.name);
    } catch (_) {}
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, AppLanguage>((ref) {
  return LanguageNotifier();
});

/// Resolves active AppLanguage: if 'auto', inspects device locale.
final activeLanguageProvider = Provider<AppLanguage>((ref) {
  final selected = ref.watch(languageProvider);
  if (selected != AppLanguage.auto) {
    return selected;
  }

  // Detect device locale
  final deviceLocale = ui.PlatformDispatcher.instance.locale;
  final code = deviceLocale.languageCode.toLowerCase();

  if (code.startsWith('es')) {
    return AppLanguage.es;
  }

  // Default international standard fallback: English
  return AppLanguage.en;
});

/// Provides the active strings dictionary
final stringsProvider = Provider<AppStrings>((ref) {
  final activeLang = ref.watch(activeLanguageProvider);
  switch (activeLang) {
    case AppLanguage.es:
      return const SpanishStrings();
    case AppLanguage.en:
    case AppLanguage.auto:
      return const EnglishStrings();
  }
});
