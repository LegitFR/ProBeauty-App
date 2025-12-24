import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:probeauty_app/app_locale.dart';
import 'package:probeauty_app/resources/AppColors.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  void _changeLanguage(BuildContext context, String languageCode) {
    context.read<AppLocale>().changeLanguage(languageCode);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softIvory,
      appBar: AppBar(
        backgroundColor: AppColors.softIvory,
        elevation: 0,
        title: const Text(
          "Select language",
          style: TextStyle(
            fontFamily: "PoppinsSemiBold",
            color: Colors.black,
          ),
        ),
        leading: const BackButton(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _langTile(context, "English", "en"),
          _langTile(context, "Français", "fr"),
          _langTile(context, "Português", "pt"),
          _langTile(context, "Español", "es"),
        ],
      ),
    );
  }

  Widget _langTile(BuildContext context, String title, String code) {
    return GestureDetector(
      onTap: () => _changeLanguage(context, code),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black),
          color: AppColors.softIvory,
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontFamily: "PoppinsSemiBold",
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
