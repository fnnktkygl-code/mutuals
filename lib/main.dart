import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/app_state.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize French locale for date formatting
  await initializeDateFormatting('fr_FR', null);
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    debugPrint('Running in offline-only mode');
  }
  
  // Initialize Notifications
  await NotificationService().init(); 
  
  // NOTE: Onboarding check is now done in SplashScreen
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState()..initialize(),
      child: const FamilleIoApp(),
    ),
  );
}

class FamilleIoApp extends StatelessWidget {
  const FamilleIoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    
    return MaterialApp(
      title: 'Mutuals',
      debugShowCheckedModeBanner: false,
      theme: appState.currentTheme,
      home: const SplashScreen(),
    );
  }
}
