// ============================================================================
// SECTION 1: IMPORTS
// ============================================================================
import 'package:flutter/material.dart'; 
import 'package:hive_flutter/hive_flutter.dart'; 
import 'screens/login_screen.dart'; 

// ============================================================================
// SECTION 2: THE MAIN EXECUTION ENGINE
// ============================================================================
void main() async {
  // Ensure Flutter is fully booted
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the local Hive Database
  await Hive.initFlutter();
  
  // Open the table that holds our usernames
  await Hive.openBox('user_database');

  // NEW: Open the table that will securely store everyone's scan history
  await Hive.openBox('scan_history');

  // Boot up the UI
  runApp(const MyApp());
}

// ============================================================================
// SECTION 3: ROOT WIDGET
// ============================================================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      title: 'Crop Doctor',
      theme: ThemeData(
        primarySwatch: Colors.green, 
      ),
      home: const LoginScreen(), // Directs the app to start at the Login Screen
    );
  }
}
