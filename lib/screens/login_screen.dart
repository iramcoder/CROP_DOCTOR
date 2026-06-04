import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'home_screen.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _newUserController = TextEditingController();
  List<String> existingUsers = [];
  final _userBox = Hive.box('user_database');
  @override
  void initState() {
    super.initState();
    _loadUsers();
  }
  void _loadUsers() {
    List<dynamic>? savedData = _userBox.get('users_list');
    setState(() {
      if (savedData == null || savedData.isEmpty) {
        existingUsers = ["Iram Hussain"];
        _userBox.put('users_list', existingUsers);
      } else {
        List<String> savedUsers = savedData.cast<String>();
        if (savedUsers.contains("Iram Hussain")) savedUsers.remove("Iram Hussain");
        existingUsers = ["Iram Hussain", ...savedUsers];
      }
    });
  }
  void _saveNewUser(String name) {
    if (!existingUsers.contains(name)) {
      setState(() => existingUsers.add(name));
      List<String> listToSave = List.from(existingUsers);
      listToSave.remove("Iram Hussain");
      _userBox.put('users_list', listToSave);
    }
  }
  void _loginAsUser(String userName, {bool isNewUser = false}) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(userName: userName, isNewUser: isNewUser),
      ),
    );
  }
  void _createNewUser() {
    String newName = _newUserController.text.trim();
    if (newName.isNotEmpty) {
      _saveNewUser(newName);
      _newUserController.clear();
      _loginAsUser(newName, isNewUser: true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a name first.")),
      );
    }
  }

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
                const Text("Crop Doctor", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF159A6C))),
                const SizedBox(height: 8),
                const Text("Who is using the app today?", style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 40),
                const Text("EXISTING PROFILES", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12, letterSpacing: 1.2)),
                const SizedBox(height: 15),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: existingUsers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => _loginAsUser(existingUsers[index], isNewUser: false),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFF159A6C).withOpacity(0.2),
                                child: const Icon(Icons.person, color: Color(0xFF159A6C)),
                              ),
                              const SizedBox(width: 15),
                              Text(existingUsers[index], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("OR", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 25),

                const Text("CREATE NEW PROFILE", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12, letterSpacing: 1.2)),
                const SizedBox(height: 15),

                TextField(
                  controller: _newUserController,
                  decoration: InputDecoration(
                    hintText: "Enter new farmer's name",
                    prefixIcon: const Icon(Icons.person_add_alt_1_outlined, color: Color(0xFF159A6C)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),

                const SizedBox(height: 15),

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
                    child: const Text("Create Profile & Start", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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