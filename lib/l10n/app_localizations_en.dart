// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Ethiopian Names App';

  @override
  String get translatedFrom => 'Translated From:';

  @override
  String get translatedTo => 'Translated To:';

  @override
  String get trySample => 'Try a sample:';

  @override
  String get suggestName => 'Suggest a Name';

  @override
  String get enterName => 'Enter name...';

  @override
  String get enterNameAmharic => 'ስም ያስገቡ...';

  @override
  String get result => 'Result...';

  @override
  String get resultAmharic => 'መልስ';

  @override
  String get oromoName => 'Afaan Oromo (Qubee)';

  @override
  String get englishName => 'English';

  @override
  String get amharicName => 'Amharic (ፊደል)';

  @override
  String get textCopied => 'Text copied to clipboard!';

  @override
  String get menu => 'Menu';

  @override
  String get home => 'Home';

  @override
  String get settings => 'Settings';

  @override
  String get about => 'About';

  @override
  String get oromoNameLabel => 'Afaan Oromo Name';

  @override
  String get englishNameLabel => 'English Name';

  @override
  String get amharicNameLabel => 'Amharic (ፊደል) Name';

  @override
  String get pleaseEnterName => 'Please enter a name';

  @override
  String get cancel => 'Cancel';

  @override
  String get submit => 'Submit';

  @override
  String get suggestionSubmitted => 'Suggestion submitted!';

  @override
  String get sendFeedback => 'Send Feedback';

  @override
  String get enterFeedback => 'Enter your feedback...';

  @override
  String get feedbackSent => 'Feedback sent!';

  @override
  String get errorOccurred => 'An error occurred.';

  @override
  String get aboutDescription =>
      'This app helps to accurately transliterate names between Afan Oromo (Qubee), English, and Amharic (ፊደል). It uses a \'database-first\' approach for common names to ensure 100% accuracy, and a rule-based engine for unique names.';

  @override
  String get developedBy =>
      'Developed by: Galgalo Doyo Adi\ngalgaloda@gmail.com';

  @override
  String get version => 'Version 1.9.0';

  @override
  String get sendFeedbackButton => 'Send Feedback';

  @override
  String get shareApp => 'Share App';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';
}
