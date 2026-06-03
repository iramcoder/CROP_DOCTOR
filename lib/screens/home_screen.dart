// ============================================================================
// SECTION 1: IMPORTS
// Bringing in the tools required for the UI, camera, and navigation.
// ============================================================================
import 'dart:typed_data'; // Allows us to handle raw image data (bytes)
import 'package:flutter/material.dart'; // Core UI tools (Scaffold, Text, etc.)
import 'package:image_picker/image_picker.dart'; // Plugin to open the phone's camera or gallery
import 'diagnose_screen.dart'; // The next screen we go to after taking a photo

// ============================================================================
// SECTION 2: THE MAIN WIDGET
// We use a StatelessWidget here because the UI on this specific screen 
// doesn't change drastically while we are looking at it.
// ============================================================================
class HomeScreen extends StatelessWidget {
  // This variable catches the name passed from the LoginScreen!
  final String userName; 

  const HomeScreen({super.key, required this.userName});

  // ==========================================================================
  // SECTION 3: HELPER METHODS (CAMERA & GALLERY)
  // These functions handle asking the user for a photo and moving to the next screen.
  // ==========================================================================

  // 1. Shows a bottom pop-up menu asking: "Camera or Gallery?"
  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Wrap tightly around the content
          children: [
            const Text(
              "Select Image Source",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Camera Button
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF159A6C)),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(bc); // Close the pop-up menu
                _pickAndNavigate(context, ImageSource.camera); // Open Camera
              },
            ),
            
            // Gallery Button
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF159A6C)),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.pop(bc); // Close the pop-up menu
                _pickAndNavigate(context, ImageSource.gallery); // Open Gallery
              },
            ),
          ],
        ),
      ),
    );
  }

  // 2. Actually opens the camera/gallery, grabs the photo, and navigates.
  Future<void> _pickAndNavigate(BuildContext context, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();

      // CRITICAL FIX: Modern phone cameras take huge 5MB+ photos. 
      // If we don't compress them using maxWidth and imageQuality, the app will run out of memory and freeze!
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1080, 
        imageQuality: 80,
      );

      // If the user actually picked an image (and didn't just hit 'cancel')
      if (image != null) {
        // Convert the image file into raw computer bytes. TFLite loves bytes.
        final Uint8List imageBytes = await image.readAsBytes();

        // Safety check: Make sure the screen is still active before trying to navigate.
        if (!context.mounted) return;

        // Jump to the AI Diagnose Screen and hand over the photo bytes!
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiagnoseScreen(imageBytes: imageBytes),
          ),
        );
      }
    } catch (e) {
      print("Error picking image: $e"); // Logs errors to the developer console
    }
  }

  // ==========================================================================
  // SECTION 4: THE USER INTERFACE (UI)
  // Building the visual dashboard.
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5), // Light grey/green background
      body: SafeArea(
        child: SingleChildScrollView( // Allows scrolling if the screen is small
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // --- HEADER: GREETING & PROFILE ICON ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      // Uses the name we passed from the login screen!
                      "Good Morning,\n$userName!", 
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C2333),
                        height: 1.3,
                      ),
                    ),
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: Color(0xFF159A6C),
                      child: Icon(Icons.person, color: Colors.white, size: 28),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // --- SEARCH BAR ---
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search crops, diseases...",
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- MAIN ACTION: SCAN A PLANT BUTTON ---
                // GestureDetector makes any widget clickable.
                GestureDetector(
                  onTap: () => _showPickerOptions(context), // Triggers our pop-up menu!
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF159A6C).withOpacity(0.12),
                      border: Border.all(color: const Color(0xFF159A6C), width: 1.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.document_scanner_outlined, color: Color(0xFF159A6C), size: 28),
                        SizedBox(width: 12),
                        Text(
                          "Scan a Plant",
                          style: TextStyle(
                            color: Color(0xFF159A6C),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // --- EDUCATIONAL BANNER ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF159A6C), Color(0xFF1DB87A)], // Nice green gradient
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Plant a seed of\nknowledge today!",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, height: 1.3),
                            ),
                            SizedBox(height: 12),
                            Text("Learn new farming techniques", style: TextStyle(fontSize: 14, color: Colors.white70)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      // Semi-transparent box for the leaf icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.eco, size: 45, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // --- FEATURE GRID (4 SQUARES) ---
                // GridView organizes children into a grid layout automatically.
                GridView.count(
                  shrinkWrap: true, // Let it calculate its own height
                  physics: const NeverScrollableScrollPhysics(), // Scroll handled by parent
                  crossAxisCount: 2, // 2 columns
                  mainAxisSpacing: 15, // Spacing between rows
                  crossAxisSpacing: 15, // Spacing between columns
                  childAspectRatio: 1.1, // Makes the boxes slightly rectangular
                  children: [
                    // We use our custom "FeatureCard" widget (defined below) to save typing!
                    FeatureCard(
                      icon: Icons.medical_services_outlined,
                      title: "Diagnose",
                      color: const Color(0xFF159A6C),
                      onTap: () => _showPickerOptions(context), 
                    ),
                    FeatureCard(
                      icon: Icons.grass,
                      title: "My Crops",
                      color: const Color(0xFF2ECC71),
                      onTap: () {}, // Future feature
                    ),
                    FeatureCard(
                      icon: Icons.wb_sunny_outlined,
                      title: "Weather",
                      color: const Color(0xFFFFA726),
                      onTap: () {}, // Future feature
                    ),
                    FeatureCard(
                      icon: Icons.people_outline,
                      title: "Community",
                      color: const Color(0xFF42A5F5),
                      onTap: () {}, // Future feature
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // --- SCAN HISTORY HEADER ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Your Scan History",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1C2333)),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text("See All", style: TextStyle(color: Color(0xFF159A6C))),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // --- STATIC SCAN HISTORY LIST ---
                // We use our custom "ActivityItem" widget to draw these cleanly.
                const ActivityItem(
                  cropName: "Tomato",
                  status: "Healthy",
                  date: "2 days ago",
                  isHealthy: true,
                ),
                const SizedBox(height: 12),
                const ActivityItem(
                  cropName: "Wheat",
                  status: "Needs Attention",
                  date: "5 days ago",
                  isHealthy: false,
                ),
                const SizedBox(height: 12),
                const ActivityItem(
                  cropName: "Corn",
                  status: "Healthy",
                  date: "1 week ago",
                  isHealthy: true,
                ),
                const SizedBox(height: 30), // Padding at the very bottom
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SECTION 5: CUSTOM REUSABLE WIDGETS
// Creating these classes allows us to reuse UI code over and over without copy-pasting.
// ============================================================================

/// A reusable square button for the 4-item grid.
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Inner colored box behind the icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 32, color: color),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1C2333)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A reusable horizontal bar to show previous scan results.
class ActivityItem extends StatelessWidget {
  final String cropName;
  final String status;
  final String date;
  final bool isHealthy;

  const ActivityItem({
    super.key,
    required this.cropName,
    required this.status,
    required this.date,
    required this.isHealthy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          /// Little Colored Dot (Green for healthy, Orange for sick)
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isHealthy ? const Color(0xFF2ECC71) : const Color(0xFFFFA726),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),

          /// Crop Info Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cropName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1C2333)),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 14,
                    color: isHealthy ? const Color(0xFF2ECC71) : const Color(0xFFFFA726),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          /// Date Text on the far right
          Text(date, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }
}
