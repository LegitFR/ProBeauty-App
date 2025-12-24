import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocale extends ChangeNotifier {
  static const String _prefKey = 'languageCode';

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  /// Supported languages (keep in sync with MaterialApp)
  static const supportedLanguages = ['en', 'pt', 'fr', 'es'];

  /// Constructor – safely initialize locale
  AppLocale(String? languageCode) {
    if (languageCode != null && supportedLanguages.contains(languageCode)) {
      _locale = Locale(languageCode);
    }
  }

  /// Change language and persist it
  Future<void> changeLanguage(String code) async {
    if (!supportedLanguages.contains(code)) return;

    _locale = Locale(code);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, code);

    notifyListeners();
  }

  /// Restore language manually (optional safety net)
  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefKey);

    if (code != null && supportedLanguages.contains(code)) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  /// Reset to system / default language
  Future<void> resetToDefault() async {
    _locale = const Locale('en');

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);

    notifyListeners();
  }
}
