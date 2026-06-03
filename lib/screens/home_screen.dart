// ============================================================================
// SECTION 1: IMPORTS
// ============================================================================
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'diagnose_screen.dart';
import 'login_screen.dart'; 
import 'history_screen.dart'; 

class HomeScreen extends StatelessWidget {
  final String userName; 
  final bool isNewUser; // --- NEW: Accepts the flag from the login screen

  const HomeScreen({super.key, required this.userName, this.isNewUser = false});

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext bc) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Select Image Source", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF159A6C)),
              title: const Text("Camera"),
              onTap: () { Navigator.pop(bc); _pickAndNavigate(context, ImageSource.camera); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF159A6C)),
              title: const Text("Gallery"),
              onTap: () { Navigator.pop(bc); _pickAndNavigate(context, ImageSource.gallery); },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndNavigate(BuildContext context, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source, maxWidth: 1080, imageQuality: 80);

      if (image != null) {
        final Uint8List imageBytes = await image.readAsBytes();
        if (!context.mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DiagnoseScreen(imageBytes: imageBytes, userName: userName)),
        );
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // --- HEADER WITH DYNAMIC GREETING ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      // --- NEW: DYNAMIC TEXT LOGIC ---
                      isNewUser 
                          ? "Welcome,\n$userName!" 
                          : "Welcome back,\n$userName!", 
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1C2333), height: 1.3)
                    ),
                    InkWell(
                      onTap: () { Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false); },
                      borderRadius: BorderRadius.circular(24),
                      child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF159A6C).withOpacity(0.15), shape: BoxShape.circle), child: const Icon(Icons.swap_horiz, color: Color(0xFF159A6C), size: 28)),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                TextField(
                  decoration: InputDecoration(
                    hintText: "Search crops, diseases...", hintStyle: const TextStyle(color: Colors.grey), prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () => _showPickerOptions(context),
                  child: Container(
                    width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    decoration: BoxDecoration(color: const Color(0xFF159A6C).withOpacity(0.12), border: Border.all(color: const Color(0xFF159A6C), width: 1.5), borderRadius: BorderRadius.circular(16)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.document_scanner_outlined, color: Color(0xFF159A6C), size: 28), const SizedBox(width: 12),
                        Text("Scan a Plant", style: TextStyle(color: Color(0xFF159A6C), fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                Container(
                  width: double.infinity, padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF159A6C), Color(0xFF1DB87A)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text("Plant a seed of\nknowledge today!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, height: 1.3)),
                          SizedBox(height: 12), Text("Learn new farming techniques", style: TextStyle(fontSize: 14, color: Colors.white70)),
                        ]),
                      ),
                      const SizedBox(width: 15),
                      Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.eco, size: 45, color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                GridView.count(
                  shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, mainAxisSpacing: 15, crossAxisSpacing: 15, childAspectRatio: 1.1,
                  children: [
                    FeatureCard(
                      icon: Icons.grass, 
                      title: "My Crops", 
                      color: const Color(0xFF2ECC71), 
                      onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryScreen(userName: userName))); }
                    ),
                    FeatureCard(
                      icon: Icons.healing_outlined, 
                      title: "Diseases", 
                      color: const Color(0xFFE74C3C), 
                      onTap: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Diseases encyclopedia coming soon!"))); }
                    ),
                    FeatureCard(icon: Icons.wb_sunny_outlined, title: "Weather", color: const Color(0xFFFFA726), onTap: () {}),
                    FeatureCard(icon: Icons.people_outline, title: "Community", color: const Color(0xFF42A5F5), onTap: () {}),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon; final String title; final Color color; final VoidCallback onTap;
  const FeatureCard({super.key, required this.icon, required this.title, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap, borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 60, height: 60, decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(14)), child: Icon(icon, size: 32, color: color)),
                const SizedBox(height: 12),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1C2333))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
