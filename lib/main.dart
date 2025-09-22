import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:async';
import 'firebase_options.dart';
import 'transliterations.dart';
import 'transliterationsrules.dart';
import 'l10n/app_localizations.dart';

// Custom Material Localizations Delegate that supports Oromo
class OromoMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const OromoMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'am', 'om'].contains(locale.languageCode);

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    // For Oromo, load English localizations
    if (locale.languageCode == 'om') {
      return await GlobalMaterialLocalizations.delegate.load(
        const Locale('en'),
      );
    }
    return await GlobalMaterialLocalizations.delegate.load(locale);
  }

  @override
  bool shouldReload(OromoMaterialLocalizationsDelegate old) => false;
}

// Custom Cupertino Localizations Delegate that supports Oromo
class OromoCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const OromoCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'am', 'om'].contains(locale.languageCode);

  @override
  Future<CupertinoLocalizations> load(Locale locale) async {
    // For Oromo, load English localizations
    if (locale.languageCode == 'om') {
      return await GlobalCupertinoLocalizations.delegate.load(
        const Locale('en'),
      );
    }
    return await GlobalCupertinoLocalizations.delegate.load(locale);
  }

  @override
  bool shouldReload(OromoCupertinoLocalizationsDelegate old) => false;
}

// --- THEME MANAGEMENT ---
class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }
}

// --- LOCALE MANAGEMENT ---
class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('en');
  String _selectedLanguageCode = 'en';

  Locale get locale => _locale;
  String get selectedLanguageCode => _selectedLanguageCode;

  // Get the correct locale for our custom localizations
  Locale get effectiveLocale => Locale(_selectedLanguageCode);

  // Get AppLocalizations for the selected language
  AppLocalizations getSelectedAppLocalizations() {
    return lookupAppLocalizations(effectiveLocale);
  }

  LocaleProvider() {
    _loadLocale();
  }

  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('languageCode') ?? 'en';
    _selectedLanguageCode = languageCode;
    _locale = Locale(languageCode);
    notifyListeners();
  }

  void setLocale(Locale locale) async {
    _selectedLanguageCode = locale.languageCode;
    _locale = locale;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', _selectedLanguageCode);
    notifyListeners();
  }
}

// --- GULANTA APPICHAA ISA GUDDAA ---
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const TransliteratorApp());
}

// --- BOCA FI QINDEESSA APPICHAA ---
class TransliteratorApp extends StatelessWidget {
  const TransliteratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            title: 'Ethiopian Names Transliteration',
            // Add these new lines for localization
            localizationsDelegates: [
              AppLocalizations.delegate,
              const OromoMaterialLocalizationsDelegate(),
              const OromoCupertinoLocalizationsDelegate(),
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('am'), Locale('om')],
            locale: localeProvider.locale,

            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

// --- SPLASH SCREEN WIDGET ---
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to HomePage after 3 seconds
    Timer(
      const Duration(seconds: 3),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use theme colors for a consistent look in light/dark mode
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. The "Alphabet Bridge" Logo
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryColor, width: 3),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Letter "A" (English) at the top
                  Positioned(
                    top: 15,
                    child: Text(
                      'D',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  // Letter "አ" (Amharic) at bottom-left
                  Positioned(
                    bottom: 15,
                    left: 25,
                    child: Text(
                      'ዽ',
                      style: GoogleFonts.notoSansEthiopic(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellow,
                      ),
                    ),
                  ),
                  // Letter "Q" (Qubee) at bottom-right
                  Positioned(
                    bottom: 15,
                    right: 25,
                    child: Text(
                      'Dh',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  // Arrow pointing from A to አ (rotated)
                  Positioned(
                    top: 50,
                    left: 35,
                    child: Transform.rotate(
                      angle: 2.1, // Radians for rotation
                      child: Icon(
                        Icons.arrow_forward,
                        color: primaryColor.withAlpha(179),
                      ),
                    ),
                  ),
                  // Arrow pointing from አ to Q
                  Positioned(
                    bottom: 20,
                    child: Icon(
                      Icons.arrow_forward,
                      color: primaryColor.withAlpha(179),
                    ),
                  ),
                  // Arrow pointing from Q to A (rotated)
                  Positioned(
                    top: 50,
                    right: 35,
                    child: Transform.rotate(
                      angle: -2.1, // Radians for rotation
                      child: Icon(
                        Icons.arrow_forward,
                        color: primaryColor.withAlpha(179),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 2. App Title
            Text(
              AppLocalizations.of(context)!.appTitle,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // 3. Loading Indicator
            CircularProgressIndicator(color: primaryColor),
          ],
        ),
      ),
    );
  }
}

// --- APP THEMES ---
class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.teal,
    scaffoldBackgroundColor: const Color(0xFFF1F5F9),
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 1,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Color(0xFF0F172A)),
    ),
    cardColor: Colors.white,
    dividerColor: Colors.grey.shade300,
    disabledColor: Colors.grey.shade100,
    colorScheme: const ColorScheme.light(
      primary: Colors.teal,
      secondary: Colors.tealAccent,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.teal,
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E293B),
      elevation: 1,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardColor: const Color(0xFF1E293B),
    dividerColor: Colors.grey.shade800,
    disabledColor: Colors.grey.shade800,
    colorScheme: const ColorScheme.dark(
      primary: Colors.teal,
      secondary: Colors.tealAccent,
    ),
  );
}

// --- GULANTA APPICHAA ISA GUDDAA (STATEFUL WIDGET) ---
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// **QAAMA MAQAA SIRRII**
// Maqaa tokko afaan sadiinuu kan qabatu
class NameEntry {
  final String oromo;
  final String english;
  final String amharic;

  const NameEntry({
    required this.oromo,
    required this.english,
    required this.amharic,
  });
}

class _HomePageState extends State<HomePage> {
  // --- JIJJIIRAMOOTA HAALAA ---
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  String _fromLang = 'om';
  String _toLang = 'am';

  // --- SEERA JIJJIIRUU ---

  // **KUUSAA MAQAA SIRRII (PERFECT NAME DATABASE)**
  // Appichi jalqaba kuusaa kana keessaa barbaada.

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_processInput);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  // --- HOJII GUDDAA JIJJIIRUU ---
  void _processInput() {
    final text = _inputController.text;
    final lowerText = text.toLowerCase();
    String result = '';

    // Tarkaanfii 1: Kuusaa maqaa sirrii keessaa barbaadi
    for (final entry in perfectTransliterations) {
      String sourceText = '';
      String targetText = '';

      if (_fromLang == 'om') sourceText = entry.oromo.toLowerCase();
      if (_fromLang == 'en') sourceText = entry.english.toLowerCase();
      if (_fromLang == 'am') sourceText = entry.amharic.toLowerCase();

      if (_toLang == 'om') targetText = entry.oromo;
      if (_toLang == 'en') targetText = entry.english;
      if (_toLang == 'am') targetText = entry.amharic;

      if (lowerText == sourceText) {
        _outputController.text = targetText;
        return;
      }
    }

    // Tarkaanfii 2: Yoo kuusaa keessaa dhabame, seera fayyadami
    if (_fromLang == _toLang) {
      result = text;
    } else if (_fromLang == 'om' && _toLang == 'am') {
      // Use the new direct map instead of the old two-step process
      result = _transliterateGenericToAmharic(text, qubeeToAmharicMap);
    } else if (_fromLang == 'en' && _toLang == 'am') {
      result = _transliterateGenericToAmharic(text, englishToAmharicMap);
    } else if (_fromLang == 'om' && _toLang == 'am') {
      result = _transliterateGenericToAmharic(text, qubeeToAmharicMap);
    } else if (_fromLang == 'am' && _toLang == 'om') {
      result = _transliterateAmharicToGeneric(text, amharicToQubeeMap, true);
    } else if (_fromLang == 'am' && _toLang == 'en') {
      result = _transliterateAmharicToGeneric(text, amharicToEnglishMap, false);
    } else if (_fromLang == 'om' && _toLang == 'en') {
      result = _transliterateGenericToGeneric(text, qubeeToEnglishMap);
    } else if (_fromLang == 'en' && _toLang == 'om') {
      result = _transliterateGenericToGeneric(text, englishToQubeeMap);
    } else {
      result = text;
    }

    _outputController.text = result;
  }

  String _simplifyOromoToEnglishStyle(String oromoText) {
    String simplified = oromoText.toLowerCase();
    simplified = simplified.replaceAll('aa', 'a');
    simplified = simplified.replaceAll('ee', 'e');
    simplified = simplified.replaceAll('ii', 'i');
    simplified = simplified.replaceAll('oo', 'o');
    simplified = simplified.replaceAll('uu', 'u');
    simplified = simplified.replaceAll('dh', 'd');
    simplified = simplified.replaceAll('ny', 'n');
    simplified = simplified.replaceAll('sh', 's');

    return simplified;
  }

  // --- HOJIIWWAN JIJJIIRUU ---
  String _transliterateGenericToAmharic(
    String text,
    Map<String, List<String>> rules,
  ) {
    StringBuffer result = StringBuffer();
    int i = 0;
    final lowerText = text.toLowerCase();

    while (i < lowerText.length) {
      String phoneme = '';
      // Find longest matching phoneme
      if (i + 1 < lowerText.length &&
          rules.containsKey(lowerText.substring(i, i + 2))) {
        phoneme = lowerText.substring(i, i + 2);
      } else if (rules.containsKey(lowerText[i])) {
        phoneme = lowerText[i];
      }

      if (phoneme.isNotEmpty) {
        final consonantForms = rules[phoneme]!;
        int phonemeLength = phoneme.length;
        String nextChar = (i + phonemeLength < lowerText.length)
            ? lowerText[i + phonemeLength]
            : '';

        // Check if next character is a vowel
        if ('aeiou'.contains(nextChar)) {
          // It's a consonant-vowel pair
          if (nextChar == 'a') {
            result.write(consonantForms[3]);
          } else if (nextChar == 'u') {
            result.write(consonantForms[1]);
          } else if (nextChar == 'i') {
            result.write(consonantForms[2]);
          } else if (nextChar == 'e') {
            result.write(consonantForms[4]);
          } else if (nextChar == 'o') {
            result.write(consonantForms[6]);
          }

          i += phonemeLength + 1; // Advance past consonant and vowel

          // Handle long vowels
          if (i < lowerText.length && lowerText[i] == nextChar) {
            i++;
          }
        } else {
          // It's a consonant cluster or end of word. Use 6th form.
          result.write(consonantForms[5]);
          i += phonemeLength; // Advance past consonant only
        }
      } else if (standaloneVowels.containsKey(lowerText[i])) {
        result.write(standaloneVowels[lowerText[i]]);
        i++;
      } else {
        // Character not in any map, just append it
        result.write(text[i]);
        i++;
      }
    }
    return result.toString();
  }

  String _transliterateAmharicToGeneric(
    String text,
    Map<String, String> rules,
    bool isQubee,
  ) {
    StringBuffer result = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      result.write(rules[text[i]] ?? text[i]);
    }
    if (isQubee) {
      return result.toString();
    }
    return result
        .toString()
        .replaceAll(RegExp(r'e(?=[a-z])'), '')
        .replaceAll(RegExp(r'e$'), '');
  }

  String _transliterateGenericToGeneric(
    String text,
    Map<String, String> rules,
  ) {
    StringBuffer result = StringBuffer();
    int i = 0;
    final lowerText = text.toLowerCase();

    while (i < lowerText.length) {
      // Prioritize longer matches (2 characters)
      String phoneme = '';
      if (i + 1 < lowerText.length &&
          rules.containsKey(lowerText.substring(i, i + 2))) {
        phoneme = lowerText.substring(i, i + 2);
      } else if (rules.containsKey(lowerText[i])) {
        phoneme = lowerText[i];
      }

      if (phoneme.isNotEmpty) {
        result.write(rules[phoneme]);
        i += phoneme.length;
      } else {
        // If no match found, append the original character
        result.write(text[i]);
        i++;
      }
    }
    return result.toString();
  }

  void _swapLanguages() {
    setState(() {
      final tempLang = _fromLang;
      _fromLang = _toLang;
      _toLang = tempLang;

      final tempText = _inputController.text;
      _inputController.text = _outputController.text;
      _outputController.text = tempText;
    });
  }

  void _onSampleNameTap(String name, String from) {
    setState(() {
      _fromLang = from;
      _toLang = 'am';
      _inputController.text = name;
    });
  }

  // --- QAAMA APPICHAA (UI) ---
  @override
  Widget build(BuildContext context) {
    final amharicTextStyle = GoogleFonts.notoSansEthiopic(fontSize: 18);
    final latinTextStyle = GoogleFonts.inter(fontSize: 18);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.appTitle)),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Text(
                AppLocalizations.of(context)!.menu,
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: Text(AppLocalizations.of(context)!.home),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(AppLocalizations.of(context)!.settings),
              onTap: () {
                Navigator.of(context).pop(); // Close the drawer
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(AppLocalizations.of(context)!.about),
              onTap: () {
                Navigator.of(context).pop(); // Close the drawer
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const AboutPage()));
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNameDialog,
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'Suggest a Name',
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLanguageSelector('translated from:', _fromLang, (val) {
                setState(() {
                  _fromLang = val!;
                  if (_fromLang == _toLang) {
                    _toLang = val == 'am' ? 'om' : 'am';
                  }
                  _processInput();
                });
              }),
              const SizedBox(height: 8),
              _buildTextBox(
                context: context,
                controller: _inputController,
                hintText: _fromLang == 'am'
                    ? AppLocalizations.of(context)!.enterNameAmharic
                    : AppLocalizations.of(context)!.enterName,
                isReadOnly: false,
                textStyle: _fromLang == 'am'
                    ? amharicTextStyle
                    : latinTextStyle,
                onClear: () => _inputController.clear(),
              ),

              const SizedBox(height: 16),
              Center(
                child: IconButton.filled(
                  icon: const Icon(Icons.swap_horiz),
                  onPressed: _swapLanguages,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildLanguageSelector('translated to:', _toLang, (val) {
                setState(() {
                  _toLang = val!;
                  if (_toLang == _fromLang) {
                    _fromLang = val == 'am' ? 'om' : 'am';
                  }
                  _processInput();
                });
              }),
              const SizedBox(height: 8),
              _buildTextBox(
                context: context,
                controller: _outputController,
                hintText: _toLang == 'am'
                    ? AppLocalizations.of(context)!.resultAmharic
                    : AppLocalizations.of(context)!.result,
                isReadOnly: true,
                textStyle: _toLang == 'am' ? amharicTextStyle : latinTextStyle,
                onCopy: () {
                  if (_outputController.text.isEmpty) return;
                  Clipboard.setData(
                    ClipboardData(text: _outputController.text),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.textCopied),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  AppLocalizations.of(context)!.trySample,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),
              _buildSampleNames(),
            ],
          ),
        ),
      ),
    );
  }

  // --- QAAMOTA Gargaartuu ---
  Widget _buildLanguageSelector(
    String label,
    String value,
    ValueChanged<String?> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            items: [
              DropdownMenuItem(
                value: 'om',
                child: Text(AppLocalizations.of(context)!.oromoName),
              ),
              DropdownMenuItem(
                value: 'en',
                child: Text(AppLocalizations.of(context)!.englishName),
              ),
              DropdownMenuItem(
                value: 'am',
                child: Text(AppLocalizations.of(context)!.amharicName),
              ),
            ],
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildTextBox({
    required BuildContext context,
    required TextEditingController controller,
    required String hintText,
    required bool isReadOnly,
    required TextStyle textStyle,
    VoidCallback? onClear,
    VoidCallback? onCopy,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black26,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: controller,
        readOnly: isReadOnly,
        maxLines: 5,
        style: textStyle,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          filled: true,
          fillColor: isReadOnly
              ? Theme.of(context).disabledColor
              : Theme.of(context).cardColor,
          suffixIcon: isReadOnly
              ? IconButton(
                  icon: Icon(Icons.copy, color: Theme.of(context).primaryColor),
                  onPressed: onCopy,
                )
              : IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: onClear,
                ),
        ),
      ),
    );
  }

  Widget _buildSampleNames() {
    final Map<String, String> sampleNames = {
      "Galgaloo": "orm",
      "Dooyyoo": "orm",
      "Adii": "orm",
      "Tolaasaa": "orm",
      "Waariyoo": "orm",
      "Guyyoo": "orm",
      "Obsaa": "orm",
      "Ibsituu": "orm",
      "Faaxee": "orm",
      "Meseret": "orm",
      "Gebree": "orm",
      "Daraartu": "orm",
      "Samuel": "eng",
      "Hanna": "eng",
    };

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      alignment: WrapAlignment.center,
      children: sampleNames.entries.map((entry) {
        return ActionChip(
          label: Text(entry.key),
          onPressed: () => _onSampleNameTap(entry.key, entry.value),
          backgroundColor: Theme.of(context).primaryColor.withAlpha(26),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.transparent),
          ),
        );
      }).toList(),
    );
  }

  // --- Forms and Dialogs for Firebase ---
  void _showAddNameDialog() {
    final TextEditingController oromoController = TextEditingController();
    final TextEditingController englishController = TextEditingController();
    final TextEditingController amharicController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.suggestName),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: oromoController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.oromoNameLabel,
                  ),
                  validator: (value) => value!.isEmpty
                      ? AppLocalizations.of(context)!.pleaseEnterName
                      : null,
                ),
                TextFormField(
                  controller: englishController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.englishNameLabel,
                  ),
                  validator: (value) => value!.isEmpty
                      ? AppLocalizations.of(context)!.pleaseEnterName
                      : null,
                ),
                TextFormField(
                  controller: amharicController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.amharicNameLabel,
                  ),
                  validator: (value) => value!.isEmpty
                      ? AppLocalizations.of(context)!.pleaseEnterName
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _submitSuggestion(
                    oromoController.text,
                    englishController.text,
                    amharicController.text,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: Text(AppLocalizations.of(context)!.submit),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitSuggestion(
    String oromo,
    String english,
    String amharic,
  ) async {
    // Tarkaanfii 3 - Kanneen armaan gadii saaqaa
    if (!mounted) return; // Mirkanneessi
    try {
      await FirebaseFirestore.instance.collection('name_suggestions').add({
        'oromo': oromo,
        'english': english,
        'amharic': amharic,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
      if (!mounted) return; // Mirkanneessi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.suggestionSubmitted),
        ),
      );
    } catch (e) {
      if (!mounted) return; // Mirkanneessi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.errorOccurred)),
      );
    }
  }
}

// --- About Page Widget ---
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.appTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.appTitle,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.aboutDescription,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              '\n${AppLocalizations.of(context)!.developedBy}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.feedback),
                  label: Text(AppLocalizations.of(context)!.sendFeedbackButton),
                  onPressed: () => _showFeedbackDialog(context),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.share),
                  label: Text(AppLocalizations.of(context)!.shareApp),
                  onPressed: _shareApp,
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: Text(
                AppLocalizations.of(context)!.version,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareApp() {
    // TODO: Replace with your app's actual store links when published
    const String appLink =
        'https://play.google.com/store/apps/details?id=your.package.name';
    const String message =
        'Check out this Ethiopian Names transliteration app!\n\n$appLink';
    Share.share(message);
  }

  void _showFeedbackDialog(BuildContext context) {
    final TextEditingController feedbackController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        // Use a different context name
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.sendFeedback),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: feedbackController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.enterFeedback,
              ),
              maxLines: 4,
              validator: (value) => value!.isEmpty
                  ? AppLocalizations.of(context)!.enterFeedback
                  : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  // Pass the correct context
                  _submitFeedback(feedbackController.text, context);
                  Navigator.of(dialogContext).pop();
                }
              },
              child: Text(AppLocalizations.of(context)!.submit),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitFeedback(String feedback, BuildContext context) async {
    // Tarkaanfii 4 - Kanneen armaan gadii saaqaa
    if (!context.mounted) return; // Mirkanneessi
    try {
      await FirebaseFirestore.instance.collection('feedback').add({
        'feedback': feedback,
        'timestamp': FieldValue.serverTimestamp(),
      });
      if (!context.mounted) return; // Mirkanneessi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.feedbackSent)),
      );
    } catch (e) {
      if (!context.mounted) return; // Mirkanneessi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.errorOccurred)),
      );
    }
  }
}

// --- Settings Page Widget ---
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return ListTile(
                  title: Text(AppLocalizations.of(context)!.darkMode),
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                    },
                  ),
                );
              },
            ),
            const Divider(),
            Consumer<LocaleProvider>(
              builder: (context, localeProvider, child) {
                return ListTile(
                  title: Text(AppLocalizations.of(context)!.language),
                  subtitle: Text(AppLocalizations.of(context)!.selectLanguage),
                  trailing: DropdownButton<Locale>(
                    value: localeProvider.locale,
                    onChanged: (Locale? newLocale) {
                      if (newLocale != null) {
                        localeProvider.setLocale(newLocale);
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: Locale('en'),
                        child: Text('English'),
                      ),
                      DropdownMenuItem(
                        value: Locale('am'),
                        child: Text('አማርኛ'),
                      ),
                      DropdownMenuItem(
                        value: Locale('om'),
                        child: Text('Afaan Oromo'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
