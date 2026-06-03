// ============================================================================
// SECTION 1: IMPORTS
// We bring in our standard design tools, the Hive database, and the HomeScreen.
// ============================================================================
import 'package:flutter/material.dart'; 
import 'package:hive_flutter/hive_flutter.dart'; // <--- NEW: Using our local NoSQL database
import 'home_screen.dart'; 

// ============================================================================
// SECTION 2: THE STATEFUL WIDGET SETUP
// ============================================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ==========================================================================
  // SECTION 3: VARIABLES & CONTROLLERS
  // ==========================================================================
  
  // Controller to read what the user types in the input box
  final TextEditingController _newUserController = TextEditingController();
  
  // Our list of active user profiles shown on screen
  List<String> existingUsers = [];
  
  // Grab our opened database box (table) that we initialized in main.dart
  final _userBox = Hive.box('user_database');

  // ==========================================================================
  // SECTION 4: STARTUP LOGIC
  // ==========================================================================
  @override
  void initState() {
    super.initState();
    _loadUsers(); // Load profiles from the database as soon as the screen opens
  }

  // ==========================================================================
  // SECTION 5: DATABASE OPERATIONS
  // Functions to read and write to our local Hive database.
  // ==========================================================================

  // 1. Loads profiles from the local Hive database box
  void _loadUsers() {
    // Read the list stored under the key 'users_list'.
    List<dynamic>? savedData = _userBox.get('users_list');
    
    setState(() {
      if (savedData == null || savedData.isEmpty) {
        // Fresh Install: Initialize with the default profile
        existingUsers = ["Iram Hussain"];
        _userBox.put('users_list', existingUsers); // Save default to database
      } else {
        // Cast the raw database list into a safe List of Strings
        List<String> savedUsers = savedData.cast<String>();
        
        // Safety Check: Ensure "Iram Hussain" is always at the very top of the list
        if (savedUsers.contains("Iram Hussain")) {
          savedUsers.remove("Iram Hussain");
        }
        existingUsers = ["Iram Hussain", ...savedUsers];
      }
    });
  }

  // 2. Saves a new profile permanently to our local Hive database box
  void _saveNewUser(String name) {
    // Prevent duplicate entries
    if (!existingUsers.contains(name)) {
      setState(() {
        existingUsers.add(name); // Add to UI list instantly
      });
      
      // Make a copy of our list, remove "Iram" so we don't save duplicates
      List<String> listToSave = List.from(existingUsers);
      listToSave.remove("Iram Hussain"); 
      
      // Overwrite the database entry with our updated list
      _userBox.put('users_list', listToSave);
    }
  }

  // ==========================================================================
  // SECTION 6: ACTIONS & NAVIGATION
  // ==========================================================================

  // Handles moving to the dashboard after selecting/creating a profile
  void _loginAsUser(String userName) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(userName: userName), 
      ),
    );
  }

  // Processes creating a new user profile
  void _createNewUser() {
    String newName = _newUserController.text.trim();
    if (newName.isNotEmpty) {
      _saveNewUser(newName); // Save to Hive Database
      _newUserController.clear(); // Clear input box
      _loginAsUser(newName); // Navigate to Home Screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a name first.")),
      );
    }
  }

  // ==========================================================================
  // SECTION 7: THE USER INTERFACE (UI)
  // (Your original design remains completely intact!)
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                // Title
                const Text(
                  "Crop Doctor",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF159A6C)),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Who is using the app today?",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // --- EXISTING PROFILES HEADER ---
                const Text(
                  "EXISTING PROFILES",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12, letterSpacing: 1.2),
                ),
                const SizedBox(height: 15),
                
                // --- USER PROFILES LIST ---
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: existingUsers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => _loginAsUser(existingUsers[index]),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFF159A6C).withOpacity(0.2),
                                child: const Icon(Icons.person, color: Color(0xFF159A6C)),
                              ),
                              const SizedBox(width: 15),
                              Text(
                                existingUsers[index],
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1C2333)),
                              ),
                              const Spacer(),
                              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 25),

                // --- THE "OR" DIVIDER ---
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("OR", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 25),

                // --- CREATE PROFILE INPUT ---
                const Text(
                  "CREATE NEW PROFILE",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12, letterSpacing: 1.2),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _newUserController,
                  decoration: InputDecoration(
                    hintText: "Enter new farmer's name",
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.person_add_alt_1_outlined, color: Color(0xFF159A6C)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 15),
                
                // --- CREATE BUTTON ---
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF159A6C),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    onPressed: _createNewUser,
                    child: const Text(
                      "Create Profile & Start",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
