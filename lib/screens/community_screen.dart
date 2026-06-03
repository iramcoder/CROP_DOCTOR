// ============================================================================
// SECTION 1: IMPORTS
// ============================================================================
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:math'; // Used to generate random cute colors for the avatars

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  // A list of maps to hold user data (Name, Scan Count, and Avatar Color)
  List<Map<String, dynamic>> communityData = [];

  // A palette of cutesy, vibrant colors for the avatars
  final List<Color> _avatarColors = [
    const Color(0xFFFF9A9E), // Soft Pink
    const Color(0xFFF39C12), // Vibrant Orange
    const Color(0xFF9B59B6), // Purple
    const Color(0xFF3498DB), // Blue
    const Color(0xFF1ABC9C), // Aqua
    const Color(0xFFF1C40F), // Yellow
    const Color(0xFFE74C3C), // Red
  ];

  @override
  void initState() {
    super.initState();
    _loadCommunityData();
  }

  // ==========================================================================
  // SECTION 2: DATABASE LOGIC
  // We fetch the list of users, then fetch the length of their scan history.
  // ==========================================================================
  void _loadCommunityData() {
    final userBox = Hive.box('user_database');
    final historyBox = Hive.box('scan_history');

    // 1. Get all registered usernames
    List<dynamic>? savedData = userBox.get('users_list');
    List<String> users = ["Iram Hussain"]; // Always include the default user

    if (savedData != null && savedData.isNotEmpty) {
      List<String> loadedUsers = savedData.cast<String>();
      for (String u in loadedUsers) {
        if (u != "Iram Hussain" && !users.contains(u)) {
          users.add(u);
        }
      }
    }

    // 2. Calculate scan counts for each user
    List<Map<String, dynamic>> tempCommunityList = [];
    final random = Random();

    for (String user in users) {
      // Fetch their history list
      List<dynamic> userHistory = historyBox.get(user, defaultValue: []);
      int scanCount = userHistory.length;

      tempCommunityList.add({
        'name': user,
        'scanCount': scanCount,
        'color': _avatarColors[random.nextInt(_avatarColors.length)], // Assign a random cute color
      });
    }

    // 3. Sort the list by who has the most scans (Leaderboard style!)
    tempCommunityList.sort((a, b) => b['scanCount'].compareTo(a['scanCount']));

    setState(() {
      communityData = tempCommunityList;
    });
  }

  // ==========================================================================
  // SECTION 3: THE USER INTERFACE
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: const Text('Community Board', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              const Row(
                children: [
                  Icon(Icons.groups_rounded, size: 36, color: Color(0xFF159A6C)),
                  SizedBox(width: 10),
                  Text(
                    "Our Farmers",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1C2333)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "See all the profiles registered on this device and the number of plants they've helped save!",
                style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.4),
              ),
              const SizedBox(height: 30),

              // --- COMMUNITY LIST ---
              Expanded(
                child: ListView.builder(
                  itemCount: communityData.length,
                  itemBuilder: (context, index) {
                    final member = communityData[index];
                    final String name = member['name'];
                    final int scans = member['scanCount'];
                    final Color avatarColor = member['color'];

                    // A crown icon for the person with the most scans!
                    final bool isTopFarmer = index == 0 && scans > 0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // --- CUTE AVATAR ---
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: avatarColor.withOpacity(0.2),
                                  child: Text(
                                    name[0].toUpperCase(),
                                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: avatarColor),
                                  ),
                                ),
                                // Show a golden crown for the #1 scanner!
                                if (isTopFarmer)
                                  const Positioned(
                                    top: -8,
                                    right: -6,
                                    child: Icon(Icons.workspace_premium, color: Color(0xFFF1C40F), size: 24),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 18),
                            
                            // --- NAME AND SUBTITLE ---
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1C2333)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isTopFarmer ? "Top Contributor" : "Active Farmer",
                                    style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),

                            // --- SCAN COUNT BADGE ---
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF159A6C).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.document_scanner_outlined, size: 16, color: Color(0xFF159A6C)),
                                  const SizedBox(width: 6),
                                  Text(
                                    "$scans",
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF159A6C)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
