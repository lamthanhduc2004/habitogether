import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/signup_screen.dart';
import 'providers/pet_provider.dart';
import 'providers/user_provider.dart';
import 'providers/notification_provider.dart';
import 'l10n/app_localizations.dart';

// Lưu ngôn ngữ vào SharedPreferences
Future<void> saveLanguage(String langCode) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('language', langCode);
}

// Lấy ngôn ngữ đã lưu
Future<String?> getSavedLanguage() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('language');
}

void main() {
  runApp(const MyAppSetup());
}

class MyAppSetup extends StatefulWidget {
  const MyAppSetup({super.key});

  @override
  State<MyAppSetup> createState() => _MyAppSetupState();
}

class _MyAppSetupState extends State<MyAppSetup> {
  late Future<String?> _savedLangFuture;

  @override
  void initState() {
    super.initState();
    _savedLangFuture = _getSavedLanguage();
  }

  Future<String?> _getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('language');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _savedLangFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final savedLang = snapshot.data;

        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => UserProvider()),
            ChangeNotifierProvider(create: (context) => PetProvider()),
            ChangeNotifierProvider(create: (context) => NotificationProvider()),
          ],
          child: MyApp(initialLocale: Locale(savedLang ?? 'en', '')),
        );
      },
    );
  }
}

class MyApp extends StatefulWidget {
  final Locale initialLocale;

  const MyApp({super.key, required this.initialLocale});

  static MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>();

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late Locale _locale;

  Locale get locale => _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
  }

  Future<void> changeLocale(Locale newLocale) async {
    setState(() {
      _locale = newLocale;
    });

    // Lưu ngôn ngữ đã chọn
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', newLocale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6200EE),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF1D1340),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', ''), Locale('vi', '')],
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

// Widget để tải trước tất cả tài nguyên
class AssetPreloader extends StatefulWidget {
  final Widget child;

  const AssetPreloader({super.key, required this.child});

  @override
  State<AssetPreloader> createState() => _AssetPreloaderState();
}

class _AssetPreloaderState extends State<AssetPreloader> {
  bool _assetsLoaded = false;

  @override
  void initState() {
    super.initState();
    _preloadAssets();
  }

  // Tải trước tất cả tài nguyên
  Future<void> _preloadAssets() async {
    try {
      // Hiển thị preloader trong 1 giây tối thiểu để người dùng có thể nhìn thấy
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _assetsLoaded = true;
      });
    } catch (e) {
      setState(() {
        _assetsLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_assetsLoaded) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', width: 150, height: 150),
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text('Đang tải dữ liệu...', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}
