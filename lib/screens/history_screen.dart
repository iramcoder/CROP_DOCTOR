// ============================================================================
// SECTION 1: IMPORTS
// ============================================================================
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // To read the database

class HistoryScreen extends StatelessWidget {
  final String userName; // We need to know who is asking for their history
  const HistoryScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    // 1. Open the database box
    final historyBox = Hive.box('scan_history');
    
    // 2. Fetch the specific user's history list (or an empty list if none exist)
    List<dynamic> rawHistory = historyBox.get(userName, defaultValue: []);
    
    // 3. Safely cast the raw data into a usable map format
    List<Map<dynamic, dynamic>> myHistory = rawHistory.cast<Map<dynamic, dynamic>>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: Text('$userName\'s Crops', style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Scan History", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1C2333))),
              const SizedBox(height: 20),

              // ==============================================================
              // EMPTY STATE UI: If the user hasn't scanned anything yet
              // ==============================================================
              if (myHistory.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 20),
                        const Text(
                          "No scans recorded yet.", 
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1C2333))
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Your diagnosed crops and their health status will appear here after your first scan.", 
                          textAlign: TextAlign.center, 
                          style: TextStyle(color: Colors.grey, fontSize: 16)
                        ),
                      ],
                    ),
                  ),
                )
              // ==============================================================
              // LIST UI: If the user has history, draw the list!
              // ==============================================================
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: myHistory.length,
                    itemBuilder: (context, index) {
                      final scan = myHistory[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ActivityItem(
                          cropName: scan['crop'] ?? "Unknown",
                          status: scan['disease'] ?? "Unknown",
                          date: scan['date'] ?? "Unknown Date",
                          isHealthy: scan['isHealthy'] ?? false,
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

// Reusable UI element for rendering a single scan record
class ActivityItem extends StatelessWidget {
  final String cropName; 
  final String status; 
  final String date; 
  final bool isHealthy;

  const ActivityItem({super.key, required this.cropName, required this.status, required this.date, required this.isHealthy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: isHealthy ? const Color(0xFF2ECC71) : const Color(0xFFFFA726), shape: BoxShape.circle)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(cropName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1C2333))),
            const SizedBox(height: 4),
            Text(status, style: TextStyle(fontSize: 14, color: isHealthy ? const Color(0xFF2ECC71) : const Color(0xFFFFA726), fontWeight: FontWeight.w500)),
          ])),
          Text(date, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }
}
