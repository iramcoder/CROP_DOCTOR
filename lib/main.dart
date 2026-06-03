// ============================================================================
// SECTION 1: IMPORTS
// We import Flutter UI elements, our new Database plugin, and our Login Screen.
// ============================================================================
import 'package:flutter/material.dart'; // Core Material design UI library
import 'package:hive_flutter/hive_flutter.dart'; // High-performance local NoSQL database plugin
import 'screens/login_screen.dart'; // Pointer to our login profile manager screen

// ============================================================================
// SECTION 2: THE MAIN EXECUTION ENGINE
// We mark main() as 'async' because database initialization happens in the background.
// ============================================================================
void main() async {
  // 1. Safety Check: Tells Flutter to fully boot up its internal engine and bindings
  // before we attempt to touch local files or communicate with native Android paths.
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Initialize the Hive Database on the phone's physical storage.
  // This automatically finds a secure directory inside the app's private sandbox.
  await Hive.initFlutter();
  
  // 3. Open a "Box" (which is essentially a table in our database).
  // We name it 'user_database'. It will permanently hold our list of usernames.
  await Hive.openBox('user_database');

  // 4. Once the database is ready and our box is open, boot up the Flutter UI.
  runApp(const MyApp());
}

// ============================================================================
// SECTION 3: THE ROOT OF THE APPLICATION
// Standard stateless container setting up global themes and directing the app
// to start immediately on our login screen.
// ============================================================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hides the red "debug" banner in the corner
      title: 'Crop Doctor',
      theme: ThemeData(
        primarySwatch: Colors.green, // Sets the global app accent color palette
      ),
      home: const LoginScreen(), // Points the launch screen directly to the Login Screen
    );
  }
}
