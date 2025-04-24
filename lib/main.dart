import 'package:finance/provider/category_provider.dart';
import 'package:finance/provider/transactionProvider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(); // <- load biến môi trường .env

  // Check if the app is running on the web and initialize Firebase accordingly
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCXCj3Yrbp9cqGBM2OC_UBBMbyo3Xy0VtI",
        authDomain: "finance-404f0.firebaseapp.com",
        projectId: "finance-404f0",
        storageBucket: "finance-404f0.firebasestorage.app",
        messagingSenderId: "821545227691",
        appId: "1:821545227691:web:fa03fb62810ad05215eeee",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  bool hasSeenOnboarding = prefs.getBool('onboarding_complete') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: MyApp(showOnboarding: !hasSeenOnboarding),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;

  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finance Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: showOnboarding ? const OnboardingScreen() : const AuthWrapper(),
    );
  }
}
