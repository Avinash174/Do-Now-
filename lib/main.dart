import 'dart:developer' as dev;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'const/app_theme.dart';
import 'firebase_options.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  dev.log('App initialization started', name: 'app');

  // Clear UI mode should be immersive on some screens, but globally we want it visible
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light, // For iOS
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  try {
    dev.log('Initializing Firebase...', name: 'app');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    dev.log('Firebase initialized successfully', name: 'app');
  } catch (e) {
    dev.log('Firebase initialization failed: $e', name: 'app', error: e);
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Do Now',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getThemeWithFonts(context),
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
